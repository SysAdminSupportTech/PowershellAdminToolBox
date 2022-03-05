Begin {
    $localHost = (Get-Item -Path Env:\COMPUTERNAME).value
    $Username = (Get-Item -Path Env:\USERNAME).value #Get the local username runing the script
    $SuccessLogPath = "\\$localHost\C$\users\$Username\Documents\RoutineMaintaintask\data\Successlog.txt"
    [string]$storePath = New-Item -Path "$env:HOMESHARE\documents\RoutineMaintainTask\Data\" -ItemType Directory -Force
    $UNC = $storePath.replace(":","$")

    #Avoid recreating the Success Save Log file
    if(-not(Test-Path $storePath\successlog.txt)){
        $SuccesslogFile = (New-Item -Path $SuccessLogPath -ItemType file).FullName
    }
    $SuccesslogFile = "$storePath\Successlog.txt"

    #Create a master csv file for applications
    if(Test-Path -Path $storePath\Masterfile.csv){
        Write-Output "Processesing Script Started..."
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
                        $tempdir = (New-Item -Path \\$Comp\C$\UCTemp\ -ItemType Directory -Force).FullName #Create a temp file in the local computer using UNC
                        
                        #Checking if new file exist or not
                        Write-Output " " >> \\$Comp\C$\UCTemp\Successlogfile.txt
                        Write-Output "Date: $(Get-Date)" >> \\$Comp\C$\UCTemp\Successlogfile.txt
                        if(Test-Path -Path $SuccesslogFile){
                            Write-Output "$Comp Status: Online" >> \\$Comp\C$\UCTemp\Successlogfile.txt
                            Write-Output "$Comp Status: Online"
                        }
                        if(-not(Test-Path -Path $tempdir\Masterfile.csv)){
                            Copy-Item -Path \\$localHost\$UNC\Masterfile.csv -Destination $tempdir -force #copy item to the remote computer UCTempdir
                        }
                        Invoke-Command -ComputerName $Comp -ScriptBlock {
                            Push-Location 'C:\Program Files\windowsApps' #set remote Computer path to windowsApp
                            $AppsName = (Import-Csv -Path c:\uctemp\Masterfile.csv).AppName
                            foreach ($App in $AppsName) {
                                Write-Output "Checking AppxPackage: $App " >> C:\uctemp\Successlogfile.txt
                                #Uninstalled AppXPackaged application
                                $AppX = (Get-AppxPackage -AllUsers -Name "*$App*" -PackageTypeFilter Bundle).PackagefullName
                                if($AppX){
                                    Write-Output "$AppX" >> C:\uctemp\Successlogfile.txt
                                    Foreach($AppXPackage in $AppX){
                                    "`n" >> C:\uctemp\Successlogfile.txt
                                       Write-Output "Removing: $AppXPackage" >> C:\uctemp\Successlogfile.txt
                                       $AppX | Remove-AppxPackage -Confirm:$false >> C:\uctemp\Successlogfile.txt
                                    }
                                } Else {
                                    Write-Output "Package Not Found" >> C:\uctemp\Successlogfile.txt
                                }
                        
                                #Check for Application Path on Windows Folder and Delete
                                Write-Output "Checking App: $App " >> C:\uctemp\Successlogfile.txt
                                $AppsPath = Get-ChildItem -Name "*$app*"
                                if($AppsPath){
                                    Write-Output "$AppsPath" >> C:\uctemp\Successlogfile.txt
                                    "`n" >> C:\uctemp\Successlogfile.txt
                                    ForEach($Path in $AppsPath){
                                        Remove-Item -Path $Path -Force -Confirm:$false -Recurse -verbose 3>> C:\uctemp\Successlogfile.txt
                                    }
                                    "`n"
                                } Else{
                                    Write-Output "Application Path cannot be found Found" >> C:\uctemp\Successlogfile.txt
                                }
                            }#End of First Foreach
                        }-ErrorAction SilentlyContinue

                        #Copy content from remote computer and delete uctemp folder from remote computers
                        Get-Content -Path "\\$Comp\C$\uctemp\Successlogfile.txt" >> "\\$localHost\C$\users\$Username\Documents\RoutineMaintaintask\data\Successlog.txt"
                        Remove-Item -Path \\$Comp\C$\uctemp -Confirm:$false -Recurse

                        #
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