# Change log for OfficeOnlineServerDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- OfficeOnlineServerDsc
  - Imports DscResource.Common module
- OfficeOnlineServerHost
  - Adds new resource OfficeOnlineServerHost

### Changed

- OfficeOnlineServerDsc
  - Updated to latest pipeline files
  - Update the README so that it says that this module should also support
    to configure Office Online Server.
- All resources
  - Get-LocalizedData from DscResource.Common is now used

## [1.5.0] - 2020-04-03

## Added

- OfficeOnlineServerDsc
  - Implemented the new DSC Community CD/CI system
  - Optin to the following Dsc Resource metatests:
    - Common Tests - Validate Module Files
    - Common Tests - Validate Script Files
    - Common Tests - Relative Path Length
    - Common Tests - Validate Markdown Links
- OfficeOnlineServerFarm
  - Added logic to make sure this resource does not interfere with
    a patch installation after a reboot
- OfficeOnlineServerInstall
  - Added check for CDROM to prevent issues with block file check
- OfficeOnlineServerInstallLanguagePack
  - Added Contextual Help information
  - Added check for CDROM to prevent issues with block file check
- OfficeOnlineServerMachine
  - Added logic to make sure this resource does not interfere with
    a patch installation after a reboot
- OfficeOnlineServerProductUpdate
  - New resource

## Changed

- OfficeOnlineServerInstall
  - Updated error code checks to force reboot
- OfficeOnlineServerMachine
  - Removed check for MachineToJoin. The resource only needs to check
    for farm join, especially with the new ProductUpdate resource.

## [1.4.0.0] - 2019-05-15

### Changed

- OfficeOnlineServerInstall
  - Updated resource to make sure the Windows Environment
    variables are loaded into the PowerShell session;
  - Updated error code checks to force reboot;
- OfficeOnlineServerMachine
  - Updated resource to make sure the Windows Environment
    variables are loaded into the PowerShell session;

### Fixed

- Created LICENSE file to match the Microsoft Open Source Team standard.
  - Fixes [Issue #35](https://github.com/PowerShell/OfficeOnlineServerDsc/issues/35)

## [1.3.0.0] - 2019-04-03

### Added

- Changes to OfficeOnlineServerDsc
  - Added pull request template and issue templates.
- OfficeOnlineServerInstall
  - Added check to test if the setup file is blocked or not;
  - Added ability to install from a UNC path, by adding server
    to IE Local Intranet Zone. This will prevent an endless wait
    caused by security warning;
- OfficeOnlineServerInstallLanguagePack
  - Added check to test if the setup file is blocked or not;
  - Added ability to install from a UNC path, by adding server
    to IE Local Intranet Zone. This will prevent an endless wait
    caused by security warning;

## [1.2.0.0] - 2018-02-08

### Fixed

- Added fix for Multiple Language Pack Installs

## [1.1.0.0] - 2017-12-20

### Added

- Added support for Language Packs installation;

## [1.0.0.0] - 2017-03-08

### Added

- Added documentation to the module to finalise for release;

### Changed

- Renamed resources to shorten names before release;
  - 'OfficeOnlineServerWebAppsFarm' becomes 'OfficeOnlineServerFarm';
  - 'OfficeOnlineServerWebAppsMachine' becomes 'OfficeOnlineServerMachine';

## [0.2.0.0] - 2016-09-21

### Fixed

- Fixed a bug that caused OfficeOnlineServerMachine to fail a test when;
  the machine to join was specified using a fully qualified domain name (FQDN);

### [0.1.0.0] - 2016-08-16

### Added

- First release of OfficeOnlineServerDsc;
