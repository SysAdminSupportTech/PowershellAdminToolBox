function Get-Localdir {
    #Connect to the user computer name 
    $connect_remote_computer = Get-ChildItem -Path .\ -Directory |
    ForEach-Object {
        $_.FullName
    }
    return $connect_remote_computer
}
$dirpath = Get-LocalFile
#This function perform action on the directory pass to him by the Get-localfile funtion
function Start-Action {
    $ext = [System.Collections.ArrayList]@('.mp4', '.mp3', '.jpg', '.jpeg', '.doc', '.pptx', '.wav', '.wmi', '.pdf', '.msg', '.png', '.xlsx', '.xls')
    ForEach ($dir in $dirpath) {
        Write-Output "Directory: $dir"
        $content_files = (Get-ChildItem -Path $dir -Recurse).FullName
        ForEach ($file in $content_files) {
            if (((Get-Item -Path $file).Extension) -in $ext) {
                $file >> Allfiles.txt
            }

        }
    }
        
}
Start-Action