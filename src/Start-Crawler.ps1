Function Start-Crawler {
<#
.DESCRIPTION
Delete files on computer running on less than 32GB

.EXAMPLES
.\Start-Crawler.ps1 -FilePath "C:\powershell.comutername.csv"
#>
    [cmdletbinding()]
    param(
        $FilePath,
        $Username
    )
    #Connect remotes computers
    $computers = (Import-Csv -Path $FilePath).ComputerName
    $username = (Import-Csv -Path $FilePath).Username
    ForEach($computer in $Computers ){
        Try{
            $conn = Test-Connection -ComputerName $computer -Quiet -Count 1
            if($conn){
                #Get All users account on the local computer
                Write-Host $computer -NoNewline
                Write-Host ":"
                Invoke-Command -ComputerName $computer -ScriptBlock {
                $UserAccounts = Get-ChildItem -Path C:\Users\ -Directory
                ForEach($user in $UserAccounts){
                    #Set Location and get users content with a specific file extention
                    Write-Host " "
                    Write-Output "Working on $user Account"
                    Push-Location "C:\Users\$user" #Push Location to users path
                    $connect_remote_computer = (Get-ChildItem -Path .\ -Recurse).FullName
                    $ext = [System.Collections.ArrayList]@('.mp4', '.mp3', '.jpg', '.jpeg', '.doc', '.pptx', '.wav', '.wmi', '.pdf', '.msg', '.png', '.xlsx', '.xls', '.vlc', '.docx', '.txt')
                    ForEach ($dir in $connect_remote_computer) {
                        $content_files = (Get-ChildItem -Path $dir -Recurse).FullName
                        ForEach ($file in $content_files) {
                            if (((Get-Item -Path $file).Extension) -in $ext) {
                                $file | Out-File .\test_file.csv -Append
                                Remove-Item -Path $file -Verbose
                            }
                        }
                    }                 
                    Pop-Location #Push back to current working directory
                }
                
                }
            } Else {
                Write-Output "$computer offline"
                }
        }Catch{}
       }
    }
     
Start-Crawler -FilePath "C:\Powershell\Scripts\test_crawler\crawler.csv" #This line of script can be modified with the file paths that contain the computers. 
    