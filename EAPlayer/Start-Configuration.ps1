#Check for the Music Module is installed or not
#Create a folder based on the user preference

Function Start-Configuration{
    [cmdletBinding()]
    param()
    #setting user directory path for runing the music files
    $usrhome = $env:HOMEPATH #Get user home dir
    $usrChoice = Read-Host "Do you want to set music directory path (Y/N)"
    switch($usrChoice){
        'Y'{
            $UsrMusicPath = Read-Host "Enter Music Path"
            if(Test-Path -Path $UsrMusicPath){
                New-Item -Path $UsrMusicPath\EAFilePath.txt -Force -ItemType File
                $usrMusicPath | Out-File $UsrMusicPath\EAFilePath.txt
                $SetMusicPath = Get-Content -Path $UsrMusicPath\EAFilePath.txt
                Push-location $SetMusicPath
            }Else{
                Write-Host "An Error Just occured. Music Path Does Not Exist" -ForegroundColor Red
            }
        }
        'N'{
            New-Item -Path $usrhome\music\EAPlayer -ItemType Directory -Force
            if(Test-Path -Path "$usrhome\music\EAPlayer"){
                New-Item -Path $usrhome\music\EAPlayer\MusicPath.txt -ItemType File -Force
                Push-Location $usrhome\music\EAPlayer
                $GetUsrMusicPath = Get-Location
                Write-Host "Your Music Path is $GetUsrMusicPath" -ForegroundColor Green
                $GetUsrMusicPath.Path | Out-File $usrhome\music\EAPlayer\MusicPath.txt -Force
            }Else{
                Write-Host "An Error Just occured. Music Path Does Not Exist" -ForegroundColor Red
            }
        }
    }
    #Creating Configuration Enviroment
 
}
Start-Configuration
#$ScriptPath = Split-Path -Resolve $MyInvocation.InvocationName