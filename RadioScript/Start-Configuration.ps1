Function Start-Configuration{
    [cmdletBinding()]
    param()
    $userEnv = $env:HOMEPATH
    Push-Location $userEnv
    #Configure the user environment
    #Importing the music modules
   # Install-Module MusicPlayer -Verbose -Scope CurrentUser
   # Import-Module MusicPlayer -verbose
    #importing the language file
    $Languages = Get-Content -Path "$userEnv\google drive\KHCONF\CONFIG\LANGUAGES.TXT" | Where-Object {$_ -notmatch "^#"}
    $LanguageCollections = [System.Collections.ArrayList]@()
    Write-Output "SELECT NUMBER TO THE LANGUAGE YOU WANT TO SET UP"
    forEach($language in $Languages){
        $langArrayIndex = $LanguageCollections.Add($language)
        Write-Output "$langArrayIndex. $language"
    }
    $userInput = Read-Host "Enter Number"
    $userChoice = $LanguageCollections[$userInput]
    Write-Output "$userChoice"
    New-Folder -Language $userChoice # this is a Function that accept user value
} 
#Creating folder function
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
#Setting up the .$profile
