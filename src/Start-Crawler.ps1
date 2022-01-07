function Get-Localdir {
    #Connect to the user computer name 
    $connect_remote_computer = Get-ChildItem -Path .\  |
    ForEach-Object {
        $_.FullName
    }
   $connect_remote_computer
}

#This function perform action on the directory pass to him by the Get-localfile funtion
function Start-Action {
    $connect_remote_computer = Get-ChildItem -Path .\
    $ext = [System.Collections.ArrayList]@('.mp4', '.mp3', '.jpg', '.jpeg', '.doc', '.pptx', '.wav', '.wmi', '.pdf', '.msg', '.png', '.xlsx', '.xls','.vlc')
    ForEach ($dir in $connect_remote_computer) {
        $content_files = (Get-ChildItem -Path $dir -Recurse).FullName
        ForEach ($file in $content_files) {
            if (((Get-Item -Path $file).Extension) -in $ext) {
                $file
            }

        }
    }      
}

Function Start-Deletion{
    param(
        $FilePath
    )
    ForEach($file in $FilePath){
        Remove-Item $file -WhatIf
    }
}
$dirpath = Get-Localdir
$all_files = Start-Action
Start-Deletion -FilePath $All_files