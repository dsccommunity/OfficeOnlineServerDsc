**Description**

The OfficeOnlineServerInstall DSC resource is used to manage the installation
of the main binaries used for either Office Web Apps 2013 or Office Online
Server 2016. It detects either products installation through a registry key,
and will install the binaries if they are not present.

Currently the only supported scenario is installation of the binaries, this
resource doesn't allow them to be uninstalled.
