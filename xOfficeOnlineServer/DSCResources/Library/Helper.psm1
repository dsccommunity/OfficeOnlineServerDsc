Function Compare-FarmOu
{
    [cmdletbinding()]

    param
    (
        [string]$OuName,
        [object]$FarmObj
    )

    $adsi = [adsisearcher]'(objectCategory=organizationalUnit)'
    $adsi.Filter = "name=$OuName"
    $ou = $adsi.FindAll()
    if($ou.path){
        $searchRoot = "," + $adsi.SearchRoot.Path -replace 'LDAP://'
        $ldapResult = $ou.path -replace $searchRoot
        Write-Verbose "ldapResult: $ldapResult"
        Write-Verbose "Current $($FarmObj.FarmOU)"
        $ldapResult -contains $FarmObj.FarmOU
    }
    else
    {
        throw "$OuName not found"
    }
}

Function Add-TrailingSlash
{
    [cmdletbinding()]

    param
    (
        [string]$Uri
    )
   
    $last = $Uri.Length -1

    If($Uri.Substring($last) -ne '/')
    {
        $Uri + '/'
    }
    Else
    {
        $Uri
    }
}
