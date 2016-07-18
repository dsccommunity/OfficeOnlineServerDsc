data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData -StringData @'
NotApartOfAFarm = It does not appear that this machine is part of an Office Online Server farm.
ChangingAppMachineConfig = Changing App Maching Configuration.
SetAppMachine = The Office Web App Machine has been Set.
RemoveAppMachine = The Office Web App Machine has been removed.
FailedRemove = Failed to remove the Web App Machine.
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $MachineToJoin
    )


    Import-Module -Name OfficeWebApps -ErrorAction Stop

    $officeWebAppsMachine = $null

    try
    {
        $officeWebAppsMachine = Get-OfficeWebAppsMachine
    }
    catch
    {
        # catch when not appart of the farm and redirect output to returned hash table
        $notInFarmError = "It does not appear that this machine is part of an Office " + `
                          "Online Server farm."
        if($_.toString() -like $notInFarmError)
        {
            Write-Verbose -Message $LocalizedData.NotApartOfAFarm
        }
        else
        {
            throw
        }
    }

    if($null -eq $officeWebAppsMachine)
    {
        $returnValue = @{
            Ensure = "Absent"
            Roles = $null
            MachineToJoin = $null
        }
    }
    else
    {
        $returnValue = @{
            Ensure = "Present"
            Roles = [System.String[]]$officeWebAppsMachine.Roles
            MachineToJoin = [System.String]$officeWebAppsMachine.MasterMachineName
        }
    }

    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String[]]
        $Roles,

        [parameter(Mandatory = $true)]
        [System.String]
        $MachineToJoin
    )

    Import-Module -Name OfficeWebApps -ErrorAction Stop

    if($Ensure -eq "Absent")
    {
        Remove-OfficeWebAppsMachine

        Write-Verbose -Message $LocalizedData.RemoveAppMachine 
    }
    else
    {
        # Due to issues with Set-OfficeWebAppsMachine not changing machine roles,
        # always remove the machine and re-add.

        try
        {
            Remove-OfficeWebAppsMachine -ErrorAction Stop
        }
        catch
        {
            Write-Verbose -Message $LocalizedData.FailedRemove
        }

        if ($null -eq $Roles)
        {
            $Roles += "All" 
        }             

        New-OfficeWebAppsMachine -MachineToJoin $MachineToJoin -Roles $Roles

        Write-Verbose -Message $LocalizedData.SetAppMachine
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String[]]
        $Roles,

        [parameter(Mandatory = $true)]
        [System.String]
        $MachineToJoin
    )

    $results = Get-TargetResource -MachineToJoin $MachineToJoin

    If($null -eq $Roles)
    {
        $Roles += "All" 
    }

    $roleCompare = Compare-Object -ReferenceObject $results.Roles -DifferenceObject $Roles

    if( ($results.Ensure -eq "Present") `
            -and ($Ensure -eq "Present") `
            -and ($results.MachineToJoin -eq $MachineToJoin) `
            -and ( $null -eq $roleCompare))
    {
        # If present and all value match return true
        return $true
    }
    elseif(($results.Ensure -eq "Absent") -and ($Ensure -eq "Absent")) 
    {
        # if absent no need to check all values
        return $true
    }
    else
    {
        return $false
    }
}

Export-ModuleMember -Function *-TargetResource

