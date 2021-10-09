Function Start-EATimeWatcher{
    Try{
        do{
            $ProgramSched = (Get-Content -Path C:\Users\DeptAdmin\Documents\codeEnv\PowershellAdminToolBox\RadioScript\Files\ProgramSchedule.json -Raw) |ConvertFrom-Json
            $jsonVal = $ProgramSched.psobject.Properties.name
            $GetTime = Get-Date -Format HH:mm:ss
            forEach($Time in $jsonVal){
                if($time -eq $Gettime){
                    $TimeGet = $time
                    Push-Location -Path "C:\Users\DeptAdmin\My Drive\KHCONF\ENGLISH\PlayList\"
                    Get-ChildItem -Name $ProgramSched.$TimeGet -Force -Recurse
                    return $ProgramSched.$TimeGet
                    Pop-Location
                } else {
                    "$GetTime"
                }
            }
        }while($true)
    }Catch{}
    #Get System Time to play folder
    #do loop
}

    Function Start-EAPlayer{
        param(
            [string][Parameter(Mandatory = $true)]$musicPath
        )
        Add-Type -AssemblyName presentationcore
        $EAPlayer = New-Object System.Windows.Media.MediaPlayer #create an instance of my program
        $Musicfiles = Get-ChildItem -Path "C:\Users\DeptAdmin\My Drive\KHCONF\ENGLISH\PlayList"
        $musics = Get-ChildItem -Path "C:\Users\DeptAdmin\My Drive\KHCONF\ENGLISH\PlayList\Music_Children"
        ForEach($music in $musics){
            "Playing Music $($music.BaseName)"
            $EAPlayer.open([uri]"$($music.FullName)")
            $EAPlayer.Play()
            Start-Sleep -Seconds 3
            $EAPlayer.Stop()
        }
        
    }

#Start-EATimeWatcher
Start-EAPlayer -musicPath "C:\Users\DeptAdmin\My Drive\KHCONF\ENGLISH\PlayList"


