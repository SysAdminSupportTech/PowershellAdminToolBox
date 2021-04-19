Function FolderAction2 {
[cmdletbinding()]
param()
Begin{}
Process{
$dirContents = Get-ChildItem -Path .\
$dirCount = (Get-ChildItem -Path .\ -Directory).count
Clear-Host
"`n"
ActionPrompt #function
"`n"
ForEach($dir in $dirContents){
    $arrayVal = $dirContents.IndexOf($dir)
    if(($dir)-is[System.IO.DirectoryInfo]){
        Write-Host "$arrayVal) $dir Directory"
    } Else {
        Write-Host "$arrayVal) $dir File"
        }

    }
}
End{}
}


Function ChildFolder{
    
   #Checking for the existence of a Directory in the current Location
   if(((Get-ChildItem -Path .\ -Directory).Count)-ne 0){
        ActionPrompt #function
        $ChildDir= Get-ChildItem -Path .\ -Directory
        ForEach($dir in $ChildDir){
            "`n"
            Write-Host "The Child direction is" $dir
            $subDirectoryCount = (Get-ChildItem $dir -Directory).Count
            #$subDirectoryCount
        }
        
           
   } Else {
        Write-Host "We have files here"
   }

}

Function ActionPrompt{ 
  
  Write-Host "(1) Open (2) Copy (3) Move (4) Delete (5) Rename (6) Check Properties (7) Create New Folder (8) Copy-Path (0) Back"
}
FolderAction
