<#DESCRIPTION
The Uninstall-UCWindowsApp uninstall Microsoft Windows Store on Multiple computer and remove any provisioned Microsoft store for newly logged on 
users.

.EXAMPLE
Uninstall-UCWindowsApp -CSVPath C:\Powershell\File\TestComps.csv

This command line Get all computers in the TestComps.csv file

.EXAMPLE
Uninstall-UCWindowsApp -CSVPath C:\Powershell\File\TestComps.csv -CSVExport C:\powershell

This command line cmdlet get all computers in the testComps.csv file and export the computers not responding on the 
network to path C:\powershell\ComputerNotResponding.csv
#>
function Uninstall-UCWindowsApp{
    [cmdletbinding()]
    param(
        [Parameter()]
        $CSVPath,

        [Parameter()]
        $CSVExport = ''
    )

    Begin{
        
    }

    Process{
      
      $Computer = (Import-Csv -Path $CSVPath).ComputerName 
      ForEach($Comp in $Computer){
         $compStatus = Test-Connection -ComputerName $Comp -Count 1 -Quiet -ErrorAction Stop
         if($compStatus){
            if(New-PSSession -ComputerName $comp -ErrorAction SilentlyContinue ){

                Remove-PSSession -ComputerName $Comp
                $Comp | Out-File $CSVExport\ComputerHandled.csv -Append

                #*****************Try/Catch error*******************
                try{
                    Write-Host $comp "Online"
                    Write-Host "Uninstalling Microsoft Windows Store on $comp" -ForegroundColor Green
                    Invoke-Command -ComputerName $Comp -ScriptBlock {
                        $StorePathLocation = "C:\Program Files\windowsApps\Microsoft.WindowsStore_12011.1001.1.0_x64__8wekyb3d8bbwe"
                        Set-Location 'C:\Program Files\windowsApps'
                        Remove-AppxPackage "Microsoft.WindowsStore_12011.1001.1.0_x64__8wekyb3d8bbwe" -AllUsers -ErrorAction stop
                        #**************Checking the Status of Windows App Store**************
                            if(Test-Path -Path $StorePathLocation){
                                Remove-Item "Microsoft.WindowsStore_12011.1001.1.0_x64__8wekyb3d8bbwe" -Recurse -Confirm:$false -Force -ErrorAction stop
                                Write-Host "WindowsApp Store Found. Uninstalltion in Progress..." -ForegroundColor Red -BackgroundColor White
                                } Else{
                                     Write-Host "WindowsApp Store Successfully uninstalled Unprovisioned for other users" -ForegroundColor DarkGreen -BackgroundColor White
                                }
                        #************End checks*************************
                        Write-Host "UnProvisioning Microsoft Store on User Computer" -ForegroundColor DarkRed
                        Remove-AppxProvisionedPackage -Online -PackageName "Microsoft.WindowsStore_12011.1001.113.0_neutral_~_8wekyb3d8bbwe"

                     }  -ErrorAction Stop
                    }
                 
                    catch [System.Management.Automation.RemoteException]{
                        $error[0].exception | ForEach-Object {
                           Write-Output $_
                        }
                 } #****************endk try/catch Error***************
               
                }   Else{
                      Write-Host $error[0].exception -ForegroundColor Red
                        $Comp | Out-File $CSVExport\WInRmError.csv -Append
                }
            
         } Else{
            Write-Host $Comp "Not Alive"
            $comp | Out-File $CSVExport\ComputerNotResponding.csv -Append

         } 
    }  
}
    End{
        Write-Host "Computer not on Network are exported to $CSVExport as ComputerNotresponding.csv" 
        Write-Host "Computer Unable to connect due to WinRM Error are exported to $CSVExport as WinRMError.csv"
        Write-Host "Computer Connected and WindowsApp Store uninstall are exported to $CSVExport as ComputerHandled.csv "
    }
}
