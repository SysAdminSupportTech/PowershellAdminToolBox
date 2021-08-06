#Windows Explorer Simulator
Function Action-buttons {
    [cmdletbinding()]
    param(
        [int]$inputObject
    )

    #Looping through the contents of the current directory and performed action based on what was selected
    $ActionLoopActive = [System.Collections.ArrayList]@()
    $ActiondirsFile = Get-ChildItem -Path .\
    ForEach ($ActionContent in $ActiondirsFile) {
        $ActionArrayVals = $ActionLoopActive.Add($ActionContent) #Adding All directories index value to the empty array created
    }

    $UserSelectedObj = $ActionLoopActive[$inputObject] #Display the File Selected and tell user What action he want to perform
    Write-Host "FILE SELECTED: $UserSelectedObj" -BackgroundColor White -ForegroundColor Black

    #Creating a static action Array and asking the user what he want to do with the file selected
    Write-Host "SELECT A NUMBER TO PERFORM AN ACTION" -ForegroundColor Green
    $keyValues = [System.Collections.ArrayList]@('Copy', 'Cut', 'Rename', 'Propertise', 'New Folder', 'New File', 'Copy Path', 'Permission', 'Get History')
    ForEach ($vals in $keyValues) {
        $ArrayVals = $keyValues.IndexOf($vals)
        Write-Host "$ArrayVals. $vals" 
    }
    $UserDecisionONSelectedFile = Read-Host "TYPE HERE"
    switch ($UserDecisionONSelectedFile) {
        0 {
            Write-Host "You Want to Copy $UserSelectedObj to Another Folder" -ForegroundColor DarkGreen
            $CopyPath = Read-Host "ENTER FILEPATH"
            #Copy Selected item to path specified by the user
            if (Test-Path $CopyPath) {
                #Checking for the existence of Same File in Directory Specified By User
                if (Test-Path -Path "$CopyPath\$UserSelectedObj") {
                    Write-Warning "$UserSelectedObj exist in this Directory"
                    #UserDecision
                    Write-Host "File Exist: WHAT DO YOU WANT NEXT"
                    Write-Host "R: For REPLACE"
                    Write-Host "D: For Duplicate"
             
                    "`n"
                    $UserDecision = Read-Host "TYPE HERE "
                    switch ($userDecision) {
                        'R' {
                            $ReplaceFile = Get-Item -Path "$CopyPath\$UserSelectedObj"
                            Write-Warning "Are You Sure You Want to Replace this file ($UserSelectedObj) (Y/N) "

                            $comfirmUserAction = Read-Host "Type Here" 
                            if ($comfirmUserAction -eq "Y") {
                                $ReplaceFile | Remove-Item
                                Copy-Item -Path .\$UserSelectedObj -Destination $CopyPath
                                Write-Host "Your File Has Been Replaced Successfully" -ForegroundColor Magenta
                            }
                            Else {
                                Write-Host "Ohhh. No Action taken. Copy aborted..."
                            }
                        } #------- End of Replace Action
                        'D' {
                            #Creatign a duplicate of the file. this means renaming it with another name
                            $FileDuplicate = Get-Item -Path $CopyPath\$UserSelectedObj
                            $userFileName = Read-Host "Type The New Name"
                            #Checking if the user type a name of file
                            if ($userFileName -ne [string]::Empty) {
                                [string]$Rename = Get-Date -DisplayHint Time
                                $RUserSelectedObj = $Rename.Replace(":", "")
                                $RUserSelectedObjDate = $RUserSelectedObj.Replace("/", "")

                                #Logical decision of confirming if content selected if a file or folder
                                if (($UserSelectedObj) -is [System.IO.DirectoryInfo]) {
                                    Write-Host "this is a directory "
                                }
                                Else {
                                    $UserSelectedObjFilePath = Get-Item $UserSelectedObj
                                    $UserSelectedObjFileExt = (Get-Item $UserSelectedObj).Extension
                                    #Create a folder on the current directory and move file. then delete folder
                                    $Null = New-Item -Path ".\temp" -ItemType Directory -Force #var $Null was assigned to silence output
                                    Copy-Item -Path $UserSelectedObjFilePath -Destination ".\temp\"
                                    #Push location and perform operation
                                    Push-Location ".\temp\"
                                    Get-ChildItem -Path ".\" -File | Rename-Item -NewName "$userFileName$RUserSelectedObjDate$UserSelectedObjFileExt"
                                    #Copy file From Pushed Location to User Specified Location and pop out 
                                    Get-ChildItem -Path .\ | Move-Item -Destination $CopyPath
                                    Pop-Location
                                    Remove-Item -Path ".\temp" -Force                                
                                }
                            }
                            Else {
                                Write-Host "File Name was not Changed. Copying File Cancelled"
                            }
                        }#------- End of Duplicate Action
                        default { "NoN of The Option Selected" }
                    }
                }
                Else {
                    Copy-Item -Path .\$UserSelectedObj -Destination $CopyPath -PassThru
                    Write-Host "Your File Has Been Copied Successfully to $CopyPath" -ForegroundColor Magenta
                } #------- End of Checking if file in the same directory

            }
            Else {
                Write-Warning "The Path ($CopyPath) You Specified Does not Exits. Please Check an try again"
            } #----- End of script for user path existed.
        } #-------------------------------- end of Copy function loop

        1 { 
            $MovePath = Read-Host "ENTER FILEPATH"
            #Copy Selected item to path specified by the user
            if (Test-Path $MovePath) {
                #Checking for file type
                if(($UserSelectedObj) -is [System.IO.DirectoryInfo]){
                    $FilePath = $UserSelectedObj.fullName
                    Move-Item -Path ".\$UserSelectedObj\" -Destination $MovePath -Force -PassThru
                    
                }Else{
                    Move-Item -Path .\$UserSelectedObj -Destination $MovePath
                    Write-host "Item Moved Succesfully" -ForegroundColor Green
                }
            }
            Else {
                Write-Warning "The Path ($MovePath) You Specified Does not Exits. Please Check an try again"
            }    
          } #------------------------- End of Move-item
        2 { write-host "YOu want to Rename" }
        3 { write-host "YOu want to Propertise" }
        4 { write-host "YOu want to New Folder" }
        5 { write-host "YOu want to New File" }
        6 { write-host "YOu want to Copy Path" }
        7 { write-host "YOu want to Permission" }
        8 { write-host "YOu want to Get History" }

    }
}
Function FolderAction {
    [cmdletbinding()]
    param()
    Begin {}
    Process {
        $Folders = [System.Collections.ArrayList]@()
        Write-Host "SELECT FROM THE NUMBER BELOW TO OPEN A FOLDER\fILES" -ForegroundColor Green
        $File_folders = Get-ChildItem .\
        ForEach ($file_folder in $File_folders) {
            $ArrayIndex = $Folders.Add($file_folder)

            if (($file_folder) -is [System.IO.DirectoryInfo]) {
                Write-Host "$arrayIndex) $file_folder Directory"
            }
            Else { Write-Host "$arrayIndex) $file_folder File" }
        } 
    }
}
#Navigation Button function
Function ChildFolder {
    #Set the current path to user choice
    #Checking for the existence of a Directory in the current Location
    if (((Get-ChildItem -Path .\ -Directory).Count) -ne 0) {
        #********************************************************
        $Contents = [System.Collections.ArrayList]@()
        Write-Host "SELECT FROM THE NUMBER BELOW TO OPEN A FOLDER\fILES" -ForegroundColor Green 
        $File_folders = Get-ChildItem .\
        ForEach ($file_folder in $File_folders) {
            $ArrayIndex = $Contents.Add($file_folder)

            if (($file_folder) -is [System.IO.DirectoryInfo]) {
                Write-Host "$arrayIndex) $file_folder Directory"
            }
            Else { Write-Host "$arrayIndex) $file_folder File" }
        } 
        "`n"
        $Userinput = Read-Host "(B) For Back: (A) Action Buttons"
        #Navigation Button
        if ($userInput -eq "B") {
            #Checking the current location path.
            $Location = Get-Location
            $UserPath = Split-Path $env:homePath -Leaf #Split user path to get the username
            $UserHome = "C:\users\$UserPath" #Set the directory to loop contents on
            if ($UserHome -eq $Location) {
                Pop-Location
                Set-Location -Path $UserHome
                User-WorkSpace
            }
            Else {
                Clear-Host
                Pop-Location
            }

        }
        #____________________________Action Function_____________________________
        ElseIf ($Userinput -eq "A") {
            $GetUserSelectedFile = [System.Collections.ArrayList] @()
            $GetDirContent = Get-ChildItem .\
            ForEach ($File in $GetDirContent) {
                $arrayVal = $GetUserSelectedFile.Add($file)
            }
            $ActionUserInput = Read-Host "Select Number of File or Directory Above."
            Action-buttons -inputObject $ActionUserInput # Passing the index value of the user to the action function
        }     
        Elseif (($Contents[$userInput]) -is [System.IO.DirectoryInfo]) {
            #Checking if a Directory is empty or not
            if ((Get-ChildItem) -eq $Null) {
                Write-Host "Sorry, This Directory is empty"
                Pop-Location
                Write-Host "Redirecting..."
                Start-Sleep -Seconds 5
                #What should be done if a folder is empty
            }
            Else {
                Clear-Host
                $userPath = $Contents[$userInput]
                Push-Location $userPath
                $Message = Get-Location
                Clear-Host
                Write-Host "You Are Currently Working $Message Directory"                
            }
        }
        Elseif (($Contents[$userInput]) -is [System.IO.FileInfo]) {
            $filePath = [System.Collections.ArrayList] @()
            $GetDirContent = Get-ChildItem .\
            ForEach ($File in $GetDirContent) {
                $Null = $filePath.Add($file)
            }

            $filePath2 = $filePath[$userInput]
            Write-Host "Processing $filePath2, Please Wait..." -ForegroundColor Green
            Invoke-Item -Path .\$filePath2
        }
        Else {
            Write-Warning "You Enter The Wrong Key: Enter (B) for Back, Or Enter The Number That Correspond to the Folder/File"
        }
           
    }
    Else {
        Clear-Host
        $filePath = [System.Collections.ArrayList] @()
        $GetDirContent = Get-ChildItem .\
        ForEach ($File in $GetDirContent) {
            $arrayVal = $filePath.Add($file)
            Write-Host "$arrayVal) $filePath"
        }
        $UserInput = Read-Host "SELECT A FILE TO OPEN OR (B) FOR BACK"
        #********************************************
        if ($userInput -eq "B") {
            Pop-Location
        }
        Else {
               
            $filePath2 = $filePath[$userInput]
            Write-Host "Processing $filePath2, Please Wait..." -ForegroundColor Green
            Invoke-Item -Path .\$filePath2
        }
    }
} 
Function RChildDir {
    #listing All Items of Root Folder
    $RContents = [System.Collections.ArrayList]@()
    Write-Host "SELECT FROM THE NUMBER BELOW TO OPEN A FOLDER\fILES" -ForegroundColor Green 
    $RFile_folders = Get-ChildItem .\
    ForEach ($Rfile_folder in $RFile_folders) {
        $ArrayIndex = $RContents.Add($Rfile_folder)
        if (($Rfile_folder) -is [System.IO.DirectoryInfo]) {
            Write-Host "$arrayIndex) $Rfile_folder Directory"
        }
        Else { Write-Host "$arrayIndex) $Rfile_folder File" }
    }
    #Requesting User input
    $Userinput = Read-Host "ENTER (B) TO GO BACK"
    if ($userInput -eq "B") {
        #Checking the current location path.
        $RLocation = Get-Location
        if ($Userinput -eq $RLocation) {
            Pop-Location
            Push-Location C:\
        }
        Else {
            Clear-Host
            Pop-Location
        }
    }
    Elseif (($RContents[$userInput]) -is [System.IO.DirectoryInfo]) {
        #Checking if a Directory is empty or not
        if ((Get-ChildItem) -eq $Null) {
            Write-Host "Sorry, This Directory is empty"
            Pop-Location
            Write-Host "Redirecting..."
            Start-Sleep -Seconds 5
            #What should be done if a folder is empty
        }
        Else {
            Clear-Host
            $userPath = $RContents[$userInput]
            Push-Location
            $Message = Get-Location
            Clear-Host
            Write-Host "You Are Currently Working $Message Directory"                
        }
    }

    Elseif (($RContents[$userInput]) -is [System.IO.FileInfo]) {
        $RfilePath = [System.Collections.ArrayList] @()
        $GetDirContent = Get-ChildItem .\
        ForEach ($File in $GetDirContent) {
            $Null = $RfilePath.Add($file)
        }

        $RfilePath2 = $RfilePath[$userInput]
        Write-Host "Processing $filePath2, Please Wait..." -ForegroundColor Green
        Invoke-Item -Path .\$RfilePath2
    }
    Else {
        Write-Warning "You Enter The Wrong Key: Enter (B) for Back, Or Enter The Number That Correspond to the Folder/File"
    }
}
Function Root-Folder {
    Process {
        Push-Location C:\
        FolderAction #function
        $Folders = [System.Collections.ArrayList]@()
        "`n"
        Get-ChildItem .\ | ForEach-Object {
            $null = $folders.Add("$_") #adding folders name to the empty array bucket
        }
        $userInput = Read-Host -Prompt "Enter A Number to Open Folder or File"
        #Checking if value seleted is a file or folder
        $UserOption = $Folders[$userInput]                 
        if ((Get-Item -path $userOption) -is [System.IO.DirectoryInfo]) {
            Try {
                $UserOption = $folders[$userInput]
                Push-Location .\$userOption
                $Message = Get-Location
                Clear-Host
                Write-Host "You Are Currently Working $Message Directory"

                #checking if the directory is empty or not, then send a message to user
                #Error Message Gotten from here.
                Write-Host "im here"
                if ((Get-ChildItem) -eq $Null) {
                    Write-Host "Sorry, This Directory is empty"
                    Pop-Location
                    Write-Host "Redirecting..."
                    Start-Sleep -Seconds 5
                    Root-Folder #Function
                }
                Else {
                    #Getting the content of the childItem
                    RchildDir #function 1
                    RChildDir #function 2
                    RChildDir #Function 3
                    RChildDir #Function 4
                    RChildDir #Function 5
                    RChildDir #Function 6
                    RChildDir #Function 7
                    RChildDir #Function 8
                    RChildDir #Function 9
                    RChildDir #Function 10
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
            Clear-Host
            Write-Host "Processing $UserOption, Please Wait..." -ForegroundColor Green
            Invoke-Item -Path .\$UserOption
            Root-folder #function
            
        } #>
    }
    End {}
}
Function User-WorkSpace {
    [cmdletbinding()]
    param()
    Begin {
        Clear-Host
        $UserPath = Split-Path $env:HomePath -Leaf #Split user path to get the username
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
        $userInput = Read-Host -Prompt "SELECT FOLDER/FILE NUMBER. ENTER (A) FOR ACTION ON FILE/FOLDER"
        $UserOption = $Folders[$userInput]
        #User input to decide what to do with the file
        Write-Host "$UserOption Selected" -ForegroundColor Black -BackgroundColor White
        $userDecision = Read-Host "(A) for File Action, (B) Proceed With UCExplorer"
        if ($userDecision -eq "A") {
            Action-buttons -inputObject $userInput
        }
        Else {
            #______________________________________________________________________________________
            #Performing Action on User Selected File
            if ($UserOption -eq "A") {
                "User Option is A. Now let us process our action folder"
                #Action-buttons -inputObject $UserOption
            }
            #Checking if value seleted is a file or folder                 
            Elseif ((Get-Item -path $HomePathSet\$userOption) -is [System.IO.DirectoryInfo]) {
                Try {
                    $UserOption = $folders[$userInput]
                    Push-Location .\$userOption
                    $Message = Get-Location
                    Clear-Host
                    Write-Host "You Are Currently Working $Message Directory"

                    #checking if the directory is empty or not, then send a message to user
                    #Error Message Gotten from here.
                    if ((Get-ChildItem) -eq $Null) {
                        Write-Host "Sorry, This Directory is empty"
                        Pop-Location
                        Write-Host "Redirecting..."
                        Start-Sleep -Seconds 5
                        User-WorkSpace
                    }
                    Else {
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
                Write-Host "Processing $UserOption, Please Wait..." -ForegroundColor Green
                Invoke-Item -Path .\$UserOption
                User-WorkSpace #function
            
            } #>
            #_______________________________________________________________________________________            
        }
            
    }
    End {}
}
Function start-UCExplorer {
    Clear-Host
    Write-Host "Welcome To PowerShell File-Explorer..." -ForegroundColor Green
    $UserRequest = Read-Host "SELECT: (W) For User-Workspace or (R) For Root Directory"
    "`n"
    switch ($UserRequest) {
        "W" { User-WorkSpace }
        "R" { Root-Folder }
    }
}
start-UCExplorer
#Action-buttons -inputObject -8
