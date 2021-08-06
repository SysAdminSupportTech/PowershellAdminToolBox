# PowershellAdminToolBox
All Powershell Administrative cmdlet
# UserClientScriptedSupport
# Introduction

 The User/Client scripted support tool is build troubleshoot frequently occurrence issues like add remote desktop user, get steward password etc. In other to use this module, make sure the powershell in your computer is run as admin not as a standard user, and set execution policy to “unrestricted”

##  Installation of UCModule

1. Run PowerShell in Administrator mode. This will require your second account to run.
2. Request to be added to the gitlab repo project
3. Clone the UserClientScriptedSupport project to your computer
4. Copy the UCModule directory to the path C:\\users\\jbethel2\\Documents\\WindowsPowershell
5. Restart the PowerShell and run as administrator.
6. Module will be automatically installed on your PowerShell Session.

### How to Use CMDLets in UCModule

```
Enable-UCRemoteLoggeOnUser
```

.DESCRIPTION

    Enable a user to remotely connect to his computer. However, this script could also be used to add users to the local groups on a user computer.

    .EXAMPLE

    Enable-UCRemoteLoggeOnUser -ComputerName NGMXL9293LFM -GroupName "Remote Desktop Users" -UserName "JBethelite"

```
File-UCTransfer
```

.Description

This script is designed to transfer multiple or single file from your computer to remote computer

.Example

File-UCTransfer -UserName JBethelite -ComputerName NGMXL9293DZ -Origin C:\\Powershell\\file.txt

The Above example send a single file to the remote computer

.Example

File-UCTransfer -UserName JBethelite -ComputerName NGMXL9293DZ -Origin C:\\Powershell\\File\\\*

The Above script transfer all the files in the File Directory. Note that transfering all content of a specific file you need to specified the (\*) asterik symbol

```
Get-UCComputerLastLogOnFromCSVFile
```

.DESCRIPTION

    This script generate all the last logon date of computers in a .csv file

    .Example

    Get-UCDeptComputerLastLogOnDate -importfile C:\\temp\\file.csv -ExportCSV C:\\temp\\

    .PARAMETER importfile

    DepartmentName: Specified the document you want to import computers from.

    .PARAMETER ExportFile

    ExportCSV: Specified the directory path without the name of the file

```
Get-UCDeptComputerLastLogOnDate
```

.DESCRIPTION

    This script generate all the last logon date in a department

    .Example

    Get-UCDeptComputerLastLogOnDate -DepartmentName legal -ExportCSV C:\\temp\\

    .PARAMETER departmentName

    DepartmentName: Specified the department your are working on

    .PARAMETER ExportCSV

    ExportCSV: Specified the directory path without the name of the file

```
Get-UCStewardPassword
```

.DESCRIPTION

Get steward password of a computer

.Example

Get-UCstewardPassword -ComputerName NGMXL9293ldz

```
Rename-UCUserProfile
```

.SYNOPSIS

    Renaming user profile for troubleshooting purpose

    .DESCRIPTION

    This cmdlet allow a technician to rename a user profile to .old for troubleshooting purpose. 

    .EXAMPLE

    Rename-UCUserProfile -ComputerName NGMXL9293LDM

     The above line accept computer as a parameter.

```
Revert-UCUserProfile
```

.SYNOPSIS

    Reverting the user profile to the correct username. Example Jbethelite.OLD to Jbethelite

    .DESCRIPTION

    This cmdlet allow a technician to revert a change his has made to a user profile. 

    .EXAMPLE

    Revert-UCUserProfile -ComputerName NGMXL9293LDM

    The above line accept computer as a parameter.

```
Uninstall-UCBlacklistedApplication_v0.1
```

.DESCRIPTION

The Uninstall-UCWindowsApp uninstall Microsoft Windows Store on Multiple computer and remove any provisioned Microsoft store for newly logged on 

users.

.EXAMPLE

Uninstall-UCWindowsApp -CSVPath C:\\Powershell\\File\\TestComps.csv

This command line Get all computers in the TestComps.csv file

.EXAMPLE

Uninstall-UCWindowsApp -CSVPath C:\\Powershell\\File\\TestComps.csv -CSVExport C:\\powershell

This command line cmdlet get all computers in the testComps.csv file and export the computers not responding on the 

network to path C:\\powershell\\ComputerNotResponding.csv
