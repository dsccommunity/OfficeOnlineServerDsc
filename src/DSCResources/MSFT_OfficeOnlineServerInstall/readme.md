# Description

The OfficeOnlineServerInstall DSC resource is used to manage the installation
of the main binaries used for either Office Web Apps 2013 or Office Online
Server 2016. It detects either products installation through a registry key,
and will install the binaries if they are not present.

Currently the only supported scenario is installation of the binaries, this
resource doesn't allow them to be uninstalled.

NOTE:
When files are downloaded from the Internet, a Zone.Identifier alternate data
stream is added to indicate that the file is potentially from an unsafe source.
To use these files, make sure you first unblock them using Unblock-File.
SPOfficeOnlineServerInstall will throw an error when it detects the file is blocked.
