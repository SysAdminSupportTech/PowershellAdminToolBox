Function New-Folder{
    [cmdletBinding()]
    param(
        [string]$Language
    )
    #Get User environ path
    $userEnv = $env:HOMEPATH
    Push-Location $userEnv
    $UserSetPath = New-Item -Path "$userEnv\google drive\KHCONF\$language\" -ItemType Directory #Creating parent directory
    Set-Location $UserSetPath #Set Location to user path
    #Creating new folder
    New-Item -Path .\PlayList -ItemType Directory
    New-Item -Path .\PlayList\Special -ItemType Directory
    New-Item -Path .\PlayList\Regular -ItemType Directory

}