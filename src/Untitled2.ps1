Function ChildFolder {
    
    #Set the current path to user choice
    #Checking for the existence of a Directory in the current Location
    if (((Get-ChildItem -Path .\ -Directory).Count) -ne 0) {
        $ChildDir = Get-ChildItem -Path .\ -Directory -Force
        ForEach ($dir in $ChildDir) {
            #$subDirectoryCount = (Get-ChildItem $dir -Directory).Count
        }
        FolderAction #function
        "`n"
        $userInput = Read-Host "SELECT AN UPTION ABOVE TO OPEN A FILE/FOLDER"
        $ChildUserOption = $ChildDir[$userInput]
        if (($ChildDir[$userInput]) -is [System.IO.DirectoryInfo]) {
            #Checking if a Directory is empty or not
            if((Get-ChildItem) -eq $Null){
                    Write-Host "Sorry, This Directory is empty"
                    Pop-Location
                    Write-Host "Redirecting..."
                    Start-Sleep -Seconds 5
                    #What should be done if a folder is empty
        }Else{
            Clear-Host
            $userPath = $ChildDir[$userInput]
            Push-Location $userPath
            $Message = Get-Location
            Write-Host "You Are Currently Working $Message Directory(This is the child Folder Acion)"                     
            }
        }
        Else {
                $filePath = [System.Collections.ArrayList] @()
                $GetDirContent = Get-ChildItem .\
                ForEach($File in $GetDirContent){
                    $Null = $filePath.Add($file)
                }

                $filePath2 = $filePath[$userInput]
                Invoke-Item -Path .\$filePath2
        }
           
  } Else {
                Clear-Host
                $filePath = [System.Collections.ArrayList] @()
                $GetDirContent = Get-ChildItem .\
                ForEach($File in $GetDirContent){
                    $arrayVal = $filePath.Add($file)
                    Write-Host "$arrayVal) $filePath"
               }
               $filePath2 = $filePath[$userInput]
                Invoke-Item -Path .\$filePath2
    }

}