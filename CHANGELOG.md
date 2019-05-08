# Change log for OfficeOnlineServerDsc

## Unreleased

* OfficeOnlineServerInstall
  * Updated resource to make sure the Windows Environment
    variables are loaded into the PowerShell session;
* OfficeOnlineServerMachine
  * Updated resource to make sure the Windows Environment
    variables are loaded into the PowerShell session;

## 1.3.0.0

* Changes to OfficeOnlineServerDsc
  * Added pull request template and issue templates.
* Created LICENSE file to match the Microsoft Open Source Team standard.
  * Fixes [Issue #35](https://github.com/PowerShell/OfficeOnlineServerDsc/issues/35)
* OfficeOnlineServerInstall
  * Added check to test if the setup file is blocked or not;
  * Added ability to install from a UNC path, by adding server
    to IE Local Intranet Zone. This will prevent an endless wait
    caused by security warning;
* OfficeOnlineServerInstallLanguagePack
  * Added check to test if the setup file is blocked or not;
  * Added ability to install from a UNC path, by adding server
    to IE Local Intranet Zone. This will prevent an endless wait
    caused by security warning;

## 1.2.0.0

* Added fix for Multiple Language Pack Installs

## 1.1.0.0

* Added support for Language Packs installation;

## 1.0

* Added documentation to the module to finalise for release;
* Renamed resources to shorten names before release;
  * 'OfficeOnlineServerWebAppsFarm' becomes 'OfficeOnlineServerFarm';
  * 'OfficeOnlineServerWebAppsMachine' becomes 'OfficeOnlineServerMachine';

## 0.2

* Fixed a bug that caused OfficeOnlineServerMachine to fail a test when;
  the machine to join was specified using a fully qualified domain name (FQDN);

### 0.1.0.0

* First release of OfficeOnlineServerDsc;
