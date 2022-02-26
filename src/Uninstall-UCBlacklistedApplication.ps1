Begin {
    $localHost = (Get-Item -Path Env:\COMPUTERNAME).value
    [string]$storePath = New-Item -Path "$env:HOMESHARE\documents\RoutineMaintainTask\Data\" -ItemType Directory -Force
    $UNC = $storePath.replace(":","$")
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
                        Write-Host $comp "Online"
                        $tempdir = (New-Item -Path \\$Comp\C$\UCTemp\ -ItemType Directory -Force).FullName #Create a temp file in the local computer using UNC

                        if(-not(Test-Path -Path $tempdir\Masterfile.csv)){
                            Copy-Item -Path \\$localHost\$UNC\Masterfile.csv -Destination $tempdir -force #copy item to the remote computer UCTempdir
                        }
                        Invoke-Command -ComputerName $Comp -ScriptBlock {
                            Push-Location 'C:\Program Files\windowsApps' #set remote Computer path to windowsApp
                            #$AppsName = @("Spotify", "Minecraft", "minecraftuwp") #List of Blacklisted Application on the computer(line Modified)
                            $AppsName = (Import-Csv -Path c:\uctemp\Masterfile.csv).AppName
                            foreach ($App in $AppsName) {
                                Write-Host "Checking AppxPackage: $App " -NoNewline
                                #Uninstalled AppXPackaged application
                                $AppX = (Get-AppxPackage -AllUsers -Name "*$App*" -PackageTypeFilter Bundle).PackagefullName
                                if($AppX){
                                    Write-Host "$AppX"
                                    Foreach($AppXPackage in $AppX){
                                    "`n"
                                       Write-Host "Removing: $AppXPackage"
                                       $AppX | Remove-AppxPackage -Confirm:$false
                                    }
                                } Else {
                                    Write-Host "Not Found AppXPackage"
                                }
                        
                                #Check for Application Path on Windows Folder and Delete
                                Write-Host "Checking App: $App " -NoNewline
                                $AppsPath = Get-ChildItem -Name "*$app*"
                                if($AppsPath){
                                    Write-Host "$AppsPath"
                                    "`n"
                                    ForEach($Path in $AppsPath){
                                        Remove-Item -Path $Path -Force -Confirm:$false -Recurse -verbose
                                    }
                                    "`n"
                                } Else{
                                    write-host "Not Found"
                                }
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