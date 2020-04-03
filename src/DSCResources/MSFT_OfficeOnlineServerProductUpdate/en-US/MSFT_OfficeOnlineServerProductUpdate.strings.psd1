ConvertFrom-StringData @'
    CheckIfFileExists = Check if the setup file exists
    VolumeIsFixedDrive = Volume is a fixed drive: Perform Blocked File test
    VolumeIsCDDrive = Volume is a CD-ROM drive: Skipping Blocked File test
    VolumeNotFound = Volume not found. Unable to determine the type. Continuing.
    CheckingStatus = Checking status now
    FileNotBlocked = File not blocked, continuing.
    GetFileInfo = Get file information from setup file
    GetOOSInfo = Getting OOS version and config info from all servers
    CheckIfUNC = Checking if SetupFile is a UNC path
    PathIsUNC = Specified SetupFile is UNC path. Adding path to Local Intranet Zone
    RemoveUNCPath = Removing added path from the Local Intranet Zone
    InstallSucceeded = Office Online Server update binary installation complete.
    RebootRequired = Office Online Server update binary installation complete, however a reboot is required.
    AlreadyInstalled = The Office Online Server update was already installed on your system. Please report an issue about this behavior at https://github.com/dsccommunity/OfficeOnlineServerDsc
'@
