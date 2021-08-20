Function start-scheduleWindowsDefenderUpdate {
    Begin{
        [String]$FileName = Get-Date
        $FileNameStrRm = $FileName.Replace(',','')
        $FileNameSlRm = $FileNameStrRm.Replace('/','')
        $FileNameDate = $FileNameSlRm.Replace(':','')

        $usrHomeShare = $env:HOMESHARE
        Push-Location $usrHomeShare\documents\
        New-Item -Path .\windowsDefenderupdate\ -ItemType Directory -Force
        $ADGroupMembers = (Get-ADGroup -Filter { Name -like "NGA-Client-*" } -SearchBase 'OU=Groups,OU=NGA,DC=bethel,DC=jw,DC=org').Name
        
    } 
    Process{
        [String]$DateCheck = (Get-date -DisplayHint date).ToString("MM/dd/yyyy")
        ForEach ($deptGroup in $ADGroupMembers) {
            Write-Output "Working on Departmental Group: $DeptGroup" | Out-File .\windowsDefenderupdate\UpdateLog$FileNameDate.txt -Append
            (Get-ADGroupMember -Identity $deptGroup).name | 
            ForEach-Object {
                $Conn = Test-Connection -ComputerName $_ -Count 1 -Quiet
                if ($Conn){
                    Write-Output "STATUS: $_ Online" | Out-File .\windowsDefenderupdate\UpdateLog$FileNameDate.txt -Append
                    Write-Output "COLLATING INFORMATION:" | Out-File .\windowsDefenderupdate\UpdateLog$FileNameDate.txt -Append
                    $IStatus = Invoke-Command -ComputerName $_ -ScriptBlock {(Get-MpComputerStatus).AntispywareSignatureVersion}
                    $LastUpdateStatus = Invoke-Command -ComputerName $_ -ScriptBlock {(Get-MpComputerStatus).AntivirusSignatureLastUpdated}
                    $CStatus = Invoke-Command -ComputerName $_ -ScriptBlock {
                        #Confirming when the Application was last update. if today bypass
                        [string]$DateCheckComp = (Get-MpComputerStatus).AntivirusSignatureLastUpdated
                        $CheckDate = $DateCheckComp.Substring(0,10)
                        if($CheckDate -eq $datecheck){
                            (Get-MpComputerStatus).AntispywareSignatureVersion
                        } Else {
                            Update-MpSignature
                            (Get-MpComputerStatus).AntispywareSignatureVersion
                        }
                    }
                    Write-Output "CURRENT_STATUS: $IStatus UPDATED_STATUS: $CStatus LAST_UPDATE_DEFINATION: $LastUpdateStatus " |
                    Out-File .\windowsDefenderupdate\UpdateLog$FileNameDate.txt -Append
                } Else {
                    continue
                }

            }
        }
    }
    End{}
}
start-scheduleWindowsDefenderUpdate