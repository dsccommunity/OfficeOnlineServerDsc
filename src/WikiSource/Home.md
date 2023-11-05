# Welcome to the OfficeOnlineServerDsc wiki

<sup>*OfficeOnlineServerDsc v#.#.#*</sup>

Here you will find all the information you need to make use of the OfficeOnlineServerDsc
DSC resources in the latest release. This includes details of the resources
that are available, current capabilities, known issues, and information to
help plan a DSC based implementation of OfficeOnlineServerDsc.

Please leave comments, feature requests, and bug reports for this module in
the [issues section](https://github.com/dsccommunity/OfficeOnlineServerDsc/issues)
for this repository.

## Deprecated resources

The documentation, examples, unit test, and integration tests have been removed
for these deprecated resources. These resources will be removed
in a future release.

*No resources are currently deprecated.*

## Getting started

To get started either:

- Install from the PowerShell Gallery using PowerShellGet by running the
  following command:

```powershell
Install-Module -Name OfficeOnlineServerDsc -Repository PSGallery
```

- Download OfficeOnlineServerDsc from the [PowerShell Gallery](https://www.powershellgallery.com/packages/OfficeOnlineServerDsc)
  and then unzip it to one of your PowerShell modules folders (such as
  `$env:ProgramFiles\WindowsPowerShell\Modules`).

To confirm installation, run the below command and ensure you see the OfficeOnlineServerDsc
DSC resources available:

```powershell
Get-DscResource -Module OfficeOnlineServerDsc
```

### Powershell

It is recommended to use Windows Management Framework (PowerShell) version 5.1.

To run PowerShell DSC you need to have PowerShell 4.0 or higher (which is included
in Windows Management Framework 4.0 or higher). This version of PowerShell is
shipped with Windows Server 2012 R2, and Windows 8.1 or higher. To use DSC
on earlier versions of Windows install the Windows Management Framework 4.0.

These DSC resources might not work with PowerShell 7.x.

### Supported Office Online Server versions**

OfficeOnlineServerDsc currently supports Office Online Server 2016 and
Office Web Apps 2013 on any OS supported by either product.

## Change log

A full list of changes in each version can be found in the [change log](https://github.com/dsccommunity/SqlServerDsc/blob/main/CHANGELOG.md).
