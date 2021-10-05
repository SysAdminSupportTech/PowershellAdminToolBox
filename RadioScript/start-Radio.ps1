<#
    Play
    Stop
    Pause
    Shuffle
    NaturalDuration
#>
Function Start-EAPlayer{
    Add-Type -AssemblyName presentationcore
    $EAPlayer = New-Object System.Windows.Media.MediaPlayer #create an instance of my program
    $ProgramSched = (Get-Content -Path C:\Users\DeptAdmin\Documents\codeEnv\PowershellAdminToolBox\RadioScript\Files\ProgramSchedule.json -Raw) |ConvertFrom-Json
    $jsonVal = $ProgramSched.psobject.Properties.name
    #Get System Time to play folder
    
    
    #do loop
    do{
        $GetTime = Get-Date -Format HH:mm:ss
        forEach($Time in $jsonVal){
            if($time -eq $Gettime){
                Write-Host "value Gotten..."
                $TimeGet = $time
                return $ProgramSched.$TimeGet
            } else {
                "$GetTime"
            }
        }
    }while($true)
    
}
Start-EAPlayer



#Get content of Folder based on set time
#$settime = Get-Date -Format HH:mm:ss #this retrive only time for get-date

#$userVal = "11:00:00 PM"
