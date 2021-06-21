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
#Navigation Button function

Function ChildFolder {
    #Set the current path to user choice
    #Checking for the existence of a Directory in the current Location
    if (((Get-ChildItem -Path .\ -Directory).Count) -ne 0) {
        #********************************************************
        $Contents = [System.Collections.ArrayList]@()
        Write-Host "SELECT FROM THE NUMBER BELOW TO OPEN A FOLDER\fILES" -ForegroundColor Green 
        $File_folders = Get-ChildItem .\
        ForEach($file_folder in $File_folders) {
            $ArrayIndex = $Contents.Add($file_folder)

            if(($file_folder) -is [System.IO.DirectoryInfo]){
                Write-Host "$arrayIndex) $file_folder Directory"
            }
            Else{Write-Host "$arrayIndex) $file_folder File"}
        } 
        "`n"
        $Userinput = Read-Host "ENTER (B) TO GO BACK"
        
        #Navigation Button
        if($userInput -eq "B"){
               #Checking the current location path.
               $Location = Get-Location
               $UserPath = Split-Path $env:homePath -Leaf #Split user path to get the username
               $UserHome = "C:\users\$UserPath" #Set the directory to loop contents on
               if($UserHome -eq $Location){
                       Pop-Location
                       Set-Location -Path $UserHome
                       User-WorkSpace
               } Else {
                        Clear-Host
                        Pop-Location
                        }

            }
        Elseif(($Contents[$userInput]) -is [System.IO.DirectoryInfo]) {
            #Checking if a Directory is empty or not
            if((Get-ChildItem) -eq $Null){
                    Write-Host "Sorry, This Directory is empty"
                    Pop-Location
                    Write-Host "Redirecting..."
                    Start-Sleep -Seconds 5
                    #What should be done if a folder is empty
        }Else{
            Clear-Host
            $userPath = $Contents[$userInput]
            Push-Location $userPath
            $Message = Get-Location
            Clear-Host
            Write-Host "You Are Currently Working $Message Directory"                
            }
        }
        Elseif(($Contents[$userInput]) -is [System.IO.FileInfo]){
                $filePath = [System.Collections.ArrayList] @()
                $GetDirContent = Get-ChildItem .\
                ForEach($File in $GetDirContent){
                    $Null = $filePath.Add($file)
                }

                $filePath2 = $filePath[$userInput]
                Write-Host "Processing $filePath2, Please Wait..." -ForegroundColor Green
                Invoke-Item -Path .\$filePath2
        } Else {
                Write-Warning "You Enter The Wrong Key: Enter (B) for Back, Or Enter The Number That Correspond to the Folder/File"
        }
           
  } Else {
                Clear-Host
                $filePath = [System.Collections.ArrayList] @()
                $GetDirContent = Get-ChildItem .\
                ForEach($File in $GetDirContent){
                    $arrayVal = $filePath.Add($file)
                    Write-Host "$arrayVal) $filePath"
               }
                $UserInput = Read-Host "SELECT A FILE TO OPEN OR (B) FOR BACK"
               #********************************************
               if($userInput -eq "B"){
                    Pop-Location
               } Else {
               
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
    ForEach($Rfile_folder in $RFile_folders) {
          $ArrayIndex = $RContents.Add($Rfile_folder)
          if(($Rfile_folder) -is [System.IO.DirectoryInfo]){
                Write-Host "$arrayIndex) $Rfile_folder Directory"
            }
            Else{Write-Host "$arrayIndex) $Rfile_folder File"}
        }
      #Requesting User input
      $Userinput = Read-Host "ENTER (B) TO GO BACK"
      if($userInput -eq "B"){
               #Checking the current location path.
               $RLocation = Get-Location
               if($Userinput -eq $RLocation){
                       Pop-Location
                       Push-Location C:\
               } Else {
                        Clear-Host
                        Pop-Location
                        }
               }
       Elseif(($RContents[$userInput]) -is [System.IO.DirectoryInfo]) {
            #Checking if a Directory is empty or not
            if((Get-ChildItem) -eq $Null){
                    Write-Host "Sorry, This Directory is empty"
                    Pop-Location
                    Write-Host "Redirecting..."
                    Start-Sleep -Seconds 5
                    #What should be done if a folder is empty
         }  Else{
                Clear-Host
                $userPath = $RContents[$userInput]
                Push-Location
                $Message = Get-Location
                Clear-Host
                Write-Host "You Are Currently Working $Message Directory"                
                }
        }

       Elseif(($RContents[$userInput]) -is [System.IO.FileInfo]){
                    $RfilePath = [System.Collections.ArrayList] @()
                    $GetDirContent = Get-ChildItem .\
                    ForEach($File in $GetDirContent){
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
Function Root-Folder{
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
            Try{
                $UserOption = $folders[$userInput]
                Push-Location .\$userOption
                $Message = Get-Location
                Clear-Host
                Write-Host "You Are Currently Working $Message Directory"

                #checking if the directory is empty or not, then send a message to user
                #Error Message Gotten from here.
                Write-Host "im here"
                if((Get-ChildItem) -eq $Null){
                    Write-Host "Sorry, This Directory is empty"
                    Pop-Location
                    Write-Host "Redirecting..."
                    Start-Sleep -Seconds 5
                    Root-Folder #Function
                } Else {
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
                Clear-Host
                Write-Host "You Are Currently Working $Message Directory"

                #checking if the directory is empty or not, then send a message to user
                #Error Message Gotten from here.
                if((Get-ChildItem) -eq $Null){
                    Write-Host "Sorry, This Directory is empty"
                    Pop-Location
                    Write-Host "Redirecting..."
                    Start-Sleep -Seconds 5
                    User-WorkSpace
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
            Write-Host "Processing $UserOption, Please Wait..." -ForegroundColor Green
            Invoke-Item -Path .\$UserOption
            User-WorkSpace #function
            
        } #>
    }
    End {}
}

Function start-UCExplorer{
Clear-Host
    Write-Host "Welcome To PowerShell File-Explorer..." -ForegroundColor Green
    $UserRequest = Read-Host "SELECT: (W) For User-Workspace or (R) For Root Directory"
    "`n"
    switch($UserRequest){
        "W"{User-WorkSpace}
        "R"{Root-Folder}
    }
}

start-UCExplorer
