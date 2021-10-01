#Check for the Music Module is installed or not
#Create a folder based on the user preference

Function Start-Configuration{
    [cmdletBinding()]
    param()
    Push-Location G:\
    $Languages = (Import-Csv -Path "G:\My Drive\KHCONF\Settings\Languages.csv").Language_Names #Creating the language directory based on the user selection
    $LanguageCollections = [System.Collections.ArrayList]@()
    Write-Output "SELECT NUMBER TO THE LANGUAGE YOU WANT TO SET UP"
    forEach($language in $Languages){
        $langArrayIndex = $LanguageCollections.Add($language)
        Write-Output "$langArrayIndex. $language"
    }
    $userInput = Read-Host "Enter Number"
    $userChoice = $LanguageCollections[$userInput]
    Write-Output "$userChoice"

    #Creating a folder based on the user selection
    New-Item -Path "G:\My Drive\KHCONF\Settings\$userChoice" -ItemType Directory -Force #Creating parent directory
    New-Item -Path "G:\My Drive\KHCONF\Settings\PlayList -ItemType Directory" -Force
    New-Item -Path "G:\My Drive\KHCONF\Settings\PlayList\Special -ItemType Directory" -Force
    New-Item -Path "G:\My Drive\KHCONF\Settings\PlayList\Regular -ItemType Directory" -Force

    #Creating a custom folder
    $confirmAF = Read-Host "Do you want to create additional Folder (Y/N)" 
    if($confirmAF){
        $confirmLang = Read-Host "Have you Added the Folder in the Additionlanguage.csv File (Y/N)"
        switch ($confirmLang) {
            "y"{}
            "N"{
                Write-Host "Please Enter the Name of the Folders Here: (5 sec)"
                Start-Sleep -Seconds 5
                $CallFile = (Start-Process -FilePath "G:\My Drive\KHCONF\Settings\AdditionalLanguage.csv" -PassThru).Id
                Write-Host $CallFile

            }
        }

    }
}
Start-Configuration
Pop-Location
