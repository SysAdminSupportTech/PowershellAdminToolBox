Function Update-UCWindowsDefender {
    [cmdletbinding()]
    param()
Begin{
    
    #check for the existence of windowsDefenderUpdate.csv
    [string]$NameTime = Get-Date -DisplayHint Time
    $NameTimeval = $NameTime.Replace(':','')
 
    $Checkfile = [System.IO.File]::Exists("C:\temp\windowsDefenderUpdate.txt")
    if(-not($Checkfile)){
     #Message to User on what to do with the file
        $MessageBox = [System.Windows.MessageBox]::Show("Copy Computers From the Mail Sent to You and Paste in the Notepad Opened.",'User Inputer','YesNoCancel','Error')
        switch($MessageBox){
            'Yes'{
                New-Item -Path "C:\temp\windowsDefenderUpdate.txt" -ItemType File
                $procID = Start-Process Notepad.exe "C:\temp\windowsDefenderUpdate.txt" -PassThru
               }
            'No' {
                    Write-Output "YOu have Cancel the Script"
                }
            default{"Program will now Exit Successfully"}
        }
        
    } Else{
             New-Item -Path "C:\temp\windowsDefenderUpdate.txt" -ItemType File
             $procID = Start-Process Notepad.exe "C:\temp\windowsDefenderUpdate.txt" -PassThru
        }
    }
Process{
    #NOTE: the CSV file you are importing should have a header name called "ComputerName"
    $Date = Get-Date -UFormat %m%d%Y
    $userHome = $env:HOMESHARE
    Wait-Process -Id $procID.Id
    $computers = Get-Content C:\temp\windowsDefenderUpdate.txt
    ForEach($comp in $computers){
        if (Test-Connection $comp -Count 1 -Quiet){
                    Write-Host "UPDATING: $comp" -ForegroundColor Green
                    Invoke-Command -ComputerName $comp -ScriptBlock{
                    Try{
                        Update-MpSignature -Verbose -ErrorAction Stop
                    }Catch [System.Management.Automation.RemoteException]{Write-Warning $error[1].Exception}
                    catch [System.Management.Automation.Remoting.PSRemotingTransportException]{Write-Warning "An Error Occur due to WinRAM cannot complete operation"}
                    catch {Write-Host "An Error Occured..."}
             } -Verbose
           }Else {Write-Host "$comp Offline"}
    }
}
End{
   $FileLocation = Read-Host "SELECT LOCATION TO SAVE FILE"
   ForEach ($comp in $computers){
   if (Test-Connection $comp -Count 1 -Quiet){
        $invoke = Invoke-Command -ComputerName $comp -ScriptBlock{
        Get-MpComputerStatus | Select-Object AntispywareSignatureVersion
        }
        $invoke | Export-Csv -Path "$FileLocation\windowsDefenderUpdate2.csv" -Append -NoTypeInformation -Force  
     }  
   } 

   Remove-Item -Path "C:\temp\windowsDefenderUpdate.txt"
}
} #Type the path to the excel file here
Update-UCWindowsDefender
