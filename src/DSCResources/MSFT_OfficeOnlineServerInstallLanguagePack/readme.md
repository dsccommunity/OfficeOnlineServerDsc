# Description

The OfficeOnlineServerInstallLanguagePack DSC resource is used to manage the
installation of the language packs used for Office Online Server 2016.

Currently the only supported scenario is installation of the binaries, this
resource doesn't allow them to be uninstalled.

NOTE:
When files are downloaded from the Internet, a Zone.Identifier alternate data
stream is added to indicate that the file is potentially from an unsafe source.
To use these files, make sure you first unblock them using Unblock-File.
SPOfficeOnlineServerInstallLanguagePack will throw an error when it detects the
file is blocked.
