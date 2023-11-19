# OfficeOnlineServerDsc

[![Build Status](https://dev.azure.com/dsccommunity/OfficeOnlineServerDsc/_apis/build/status/dsccommunity.OfficeOnlineServerDsc?branchName=master)](https://dev.azure.com/dsccommunity/OfficeOnlineServerDsc/_build/latest?definitionId=29&branchName=master)
![Azure DevOps coverage (branch)](https://img.shields.io/azure-devops/coverage/dsccommunity/OfficeOnlineServerDsc/29/master)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/dsccommunity/OfficeOnlineServerDsc/29/master)](https://dsccommunity.visualstudio.com/OfficeOnlineServerDsc/_test/analytics?definitionId=29&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/OfficeOnlineServerDsc?label=OfficeOnlineServerDsc%20Preview)](https://www.powershellgallery.com/packages/OfficeOnlineServerDsc/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/OfficeOnlineServerDsc?label=OfficeOnlineServerDsc)](https://www.powershellgallery.com/packages/OfficeOnlineServerDsc/)

This module contains DSC resources for deployment and configuration of Office Online Server (formerly known as Office Web App Server).

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Installation

To manually install the module, download the source code and unzip the contents
of the \Modules\OfficeOnlineServerDsc directory to the
$env:ProgramFiles\WindowsPowerShell\Modules folder.

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0)
run the following command:

    Find-Module -Name OfficeOnlineServerDsc -Repository PSGallery | Install-Module

To confirm installation, run the below command and ensure you see the Office
Online Server DSC resoures available:

    Get-DscResource -Module OfficeOnlineServerDsc

## Requirements

The minimum PowerShell version required is 4.0, which ships in Windows 8.1 or
Windows Server 2012R2 (or higher versions). The preferred version is PowerShell
5.0 or higher, which ships with Windows 10 or Windows Server 2016.

## Changelog

A full list of changes in each version can be found in the [change log](CHANGELOG.md)

## Code of Conduct

This project has adopted this [Code of Conduct](CODE_OF_CONDUCT.md).

## Releases

For each merge to the branch `master` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).
