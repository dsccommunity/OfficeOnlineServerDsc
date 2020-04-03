# Historic change log for OfficeOnlineServerDsc

The release notes in the PowerShell Module manifest cannot exceed 10000
characters. Due to a bug in the CI deploy pipeline this is not handled.
This file is to temporary move the older change log history to keep the
change log short.

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
