Function Start-Configuration{
    [cmdletBinding()]
    param()
    Push-Location G:\
    #Configure the user environment
    #Importing the music modules
   # Install-Module MusicPlayer -Verbose -Scope CurrentUser
   # Import-Module MusicPlayer -verbose
    #importing the language file
    $Languages = Get-Content -Path "$userEnv\google drive\KHCONF\CONFIG\LANGUAGES.TXT" | Where-Object {$_ -notmatch "^#"} #Get the content of the display list
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

