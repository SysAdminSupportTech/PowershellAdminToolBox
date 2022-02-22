Begin {
    $storePath = New-Item -Path "$env:HOMESHARE\documents\RoutineMaintainTask\" -Name "Data" -ItemType Directory -Force
    #Create a master csv file for applications
    if(Test-Path -Path $storePath\Data\Masterfile.csv){
        
    } Else {
        New-Item -Path $storePath\Masterfile.csv -ItemType File -Force
        Set-Content -Path $storePath\Masterfile.csv -Value "AppName"
        Write-Output "A master file has been created, please edit to add the blacklisted applications."
        Start-Sleep 5
        $MasterfileProcID = (Start-Process -FilePath $storePath\Masterfile.csv -PassThru).Id
        Wait-Process -Id $MasterFileProcId
    }

}
Process {
      (Get-ADGroup -Filter { name -like "*nga-client*" } -SearchBase "OU=Groups,OU=NGA,DC=bethel,DC=jw,DC=org").NAME |
    ForEach-Object {
        $ADgroupComputers = (Get-ADGroupMember $_ -Recursive).Name
        ForEach ($Comp in $ADgroupComputers) {
            $CompStatus = Test-Connection -ComputerName $Comp -Count 1 -Quiet -ErrorAction Stop
            if ($compStatus) {
                if (New-PSSession -ComputerName $comp -ErrorAction SilentlyContinue ) {
                    Remove-PSSession -ComputerName $Comp
                    #*****************Try/Catch error*******************
                    try {
                        Write-Host $comp "Online"
                        Invoke-Command -ComputerName $Comp -ScriptBlock {
                            Push-Location 'C:\Program Files\windowsApps' #set remote Computer path to windowsApp
                            $AppsName = @("Spotify", "Minecraft", "minecraftuwp") #List of Blacklisted Application on the computer
                            foreach ($App in $AppsName) {
                                #Uninstalled AppXPackaged application
                                #Get-AppxPackage -AllUsers -Name "*$App*" -PackageTypeFilter Bundle | 
                                #Select-Object -ExpandProperty PackageFullName | Remove-AppxPackage -Confirm:$false
                        
                                #Check for Application Path on Windows Folder and Delete
                                $AppsPath = Get-ChildItem -Name "*$app*"
                                forEach ($Path in $AppsPath) { 
                                    #Remove-Item -Path $Path -Force -Confirm:$false -Recurse
                                    #Checking if the file path is deleted or not
                                    if (Test-Path $Path) {
                                        Write-Output "Unable to delete the specified Path $path"
                                    }
                                    Else {
                                        Write-Output "Path has Been Deleted Successfully."
                                        $Comp | Out-File $CSVExport\ComputerHandled.csv -Append
                                    }
                                }#End of inner foreach
                            }#End of First Foreach
                        }-ErrorAction SilentlyContinue
                    }
                    catch [System.Management.Automation.RemoteException] {
                        $RenameFile = Get-Date -Format "MM/dd/yyyy"
                        $CatalogDate = Get-Date -Format "MM/dd/yyyy HH:mm"
                        $NewFileName = $RenameFile.Replace("/", "")
                        $error[0].exception | ForEach-Object {
                            "$comp", "_______$CatalogDate_______" | Out-File -FilePath $storePath\"Error$NewFileName.txt" -Append
                        }
                    }#end try/catch Error
               
                }#End of pssession
                Else{
                    #Creating a name format for log file
                    $RenameFile = Get-Date -Format "MM/dd/yyyy"
                    $CatalogDate = Get-Date -Format "MM/dd/yyyy HH:mm"
                    $NewFileName = $RenameFile.Replace("/", "")
                    $error[0].exception | ForEach-Object {
                        $_, "______$CatalogDate______" | Out-File -FilePath $storePath\"Error$NewFileName.txt" -Append
                    }
                }
            } # Else block not required 
        } 
    } 
}
End {}