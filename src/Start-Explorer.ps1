#Windows Explorer Simulator
Function ActionPrompt { 
  
    Write-Host "(1) Open (2) Copy (3) Move (4) Delete (5) Rename (6) Check Properties (7) Create New Folder (8) Copy-Path (0) Back"
}
Function FolderAction {
    [cmdletbinding()]
    param()
    Begin {}
    Process {
        $Folders = [System.Collections.ArrayList]@()
        Write-Host "SELECT FROM THE NUMBER BELOW TO OPEN A FOLDER\fILES" -ForegroundColor Green
        $File_folders = Get-ChildItem .\
        ForEach($file_folder in $File_folders) {
            $ArrayIndex = $Folders.Add($file_folder)

            if(($file_folder) -is [System.IO.DirectoryInfo]){
                Write-Host "$arrayIndex) $file_folder Directory"
            }
            Else{Write-Host "$arrayIndex) $file_folder File"}
        }
         
    }
}
Function ChildFolder {
    Clear-Host
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
                    start-UCExplorer
              }Else{
            $userPath = $ChildDir[$userInput]
            Push-Location $userPath
            $Message = Get-Location
            Write-Host "You Are Currently Working $Message Directory"
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
           
    }
    Else {}
}
Function start-UCExplorer {
    [cmdletbinding()]
    param()
    Begin {
        Clear-Host
        $UserPath = Split-Path $env:homePath -Leaf #Split user path to get the username
        $HomePathSet = "C:\users\$UserPath" #Set the directory to loop contents on
        Set-Location $HomePathSet #set Path to user home path
    }
    Process {
        FolderAction #function
        $Folders = [System.Collections.ArrayList]@()
        "`n"
        Get-ChildItem .\ | ForEach-Object {
            $null = $folders.Add("$_") #adding folders name to the empty array bucket
        }
        $userInput = Read-Host -Prompt "Enter A Number to Open Folder or File"
        #Checking if value seleted is a file or folder
        $UserOption = $Folders[$userInput]                 
        if ((Get-Item -path $HomePathSet\$userOption) -is [System.IO.DirectoryInfo]) {
            Try{
                $UserOption = $folders[$userInput]
                Push-Location .\$userOption
                $Message = Get-Location
                Write-Host "You Are Currently Working $Message Directory)"

                #checking if the directory is empty or not, then send a message to user
                #Error Message Gotten from here.
                if((Get-ChildItem) -eq $Null){
                    Write-Host "Sorry, This Directory is empty"
                    Pop-Location
                    Write-Host "Redirecting..."
                    Start-Sleep -Seconds 5
                    start-UCExplorer
                } Else {
                        #Getting the content of the childItem
                        ChildFolder #function 1
                        ChildFolder #function 2
                        ChildFolder #function 3
                        ChildFolder #function 4
                        ChildFolder #function 5
                        ChildFolder #function 6
                        ChildFolder #function 7
                        ChildFolder #function 8
                        ChildFolder #function 9
                        ChildFolder #function 10
                        ChildFolder #function 11
                        ChildFolder #function 12
                        ChildFolder #function 13
                        ChildFolder #function 14
                        ChildFolder #function 15
                        ChildFolder #function 16
                        ChildFolder #function 17
                        ChildFolder #function 18
                        ChildFolder #function 19
                        ChildFolder #function 20 
                }
                 
                }
                Catch [System.ComponentModel.Win32Exception] {
                    $Error[0].exception
                }
                Catch [System.Management.Automation.RuntimeException] {
                    $Error[0].exception
                }
            
        }
        Else {
            Invoke-Item -Path .\$UserOption
            
        } #>
    }
    End {}
}
start-UCExplorer
