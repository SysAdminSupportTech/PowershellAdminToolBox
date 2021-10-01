<#
    Play
    Stop
    Pause
    Shuffle
    NaturalDuration
#>

Add-Type -AssemblyName presentationcore
$EAPlayer = New-Object System.Windows.Media.MediaPlayer #create an instance of my program
$ProgramSched = Get-Content -Path C:\Users\DeptAdmin\Documents\codeEnv\PowershellAdminToolBox\RadioScript\Files\ProgramSchedule.json |
ConvertTo-Json

#Get content of Folder based on set time
$settime = Get-Date -Format HH:mm:ss #this retrive only time for get-date

