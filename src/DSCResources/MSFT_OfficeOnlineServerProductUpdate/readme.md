# Description

**Type:** Common
**Requires CredSSP:** No

This resource is used to perform the update step of installing Office Online
Server updates, like Cumulative Updates and Service Packs. The SetupFile
parameter should point to the update file. The Servers parameter specifies
all servers in the OOS farm.

NOTE:
When files are downloaded from the Internet, a Zone.Identifier alternate data
stream is added to indicate that the file is potentially from an unsafe source.
To use these files, make sure you first unblock them using Unblock-File.
OfficeOnlineServerProductUpdate will throw an error when it detects the file
is blocked.

NOTE 2:
This resource can be used to deploy updates during the installation of Office
Online Server or when it is fully configured. This module follows the patching
procedure specified in the following article:
https://docs.microsoft.com/en-us/officeonlineserver/apply-software-updates-to-office-online-server
