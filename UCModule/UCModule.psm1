

Function Get-UCComputersEventlog{

    <#
    .DESCRIPTION
    This script is designed to collect all the logs files on all bethel domain computer. However, this logs files are only limited to system and security logs
    
    .SYNOPSIS
    Get-UCComputersEventlog function get all the systems and security logs on bethel computer.

    .PARAMETER 
    -GroupName <String>: Specified the group name that a computer belongs to
    -LogError <SwitchedParameter>: Specified if you want an error to be written to a file or not.

    .EXAMPLE
    Example 1: Get all logs of computer in nga-cd-clients grouop without logging error message to a file
    Get-UCComputersEventLog -groupName nga-cd-clients

    Example 2: Get the logs of all computer in a specific group and write error logs to a file
    Get-UCComputersERrorLog - groupName nga-cd-clients -LogErrors
#>

    [Cmdletbinding ()]
param (
[parameter(Mandatory=$true,
valueFromPipeLine=$true)] $groupName,
[switch]$LogErrors,
$exportFileLocation
)
#-----------Pending Development--------------------------------Declearing the start and End Date -------------------------------------------------
<#$Str_date = Read-Host 'Enter Start Date (mm/dd/yyyy)'
$start_Date = Get-date $Str_date

$input_End_Date = Read-Host 'Enter End Date (mm/dd/yyyy)'
$End_Date = Get-Date -Date $input_End_Date
#>

#-------------------------------------------Create a Folder in C:\ write files to it---------------------------------------------
if(Test-path -path C:\file){
    Write-Verbose "A Folder Called Filed exist in this path"
    Get-ADGroupMember -Identity $groupName | Select-Object name |Export-Csv 'C:\File\ApplicationErrorLog.csv' -NoTypeInformation
} Else {
    Write-Verbose "No Folder Called File Exist in the Path, Folder Created"
    New-Item -Name File -itemType Directory -Path C:\
    Get-ADGroupMember -Identity $groupName | Select-Object name |Export-Csv 'C:\File\ApplicationErrorLog.csv' -NoTypeInformation
}

#-------------------------------------------Importing file applicattionErrorLog From File------------------------------------------
$impComps = Import-Csv -Path C:\File\ApplicationErrorLog.csv

#------------------------------------------Using For Each to loop through each Computer--------------------------------------------

Foreach($comps in $impComps.name) {
    try {
        Invoke-Command -ComputerName $comps -ScriptBlock {Get-EventLog -LogName Security -EntryType FailureAudit |
        Select-Object MachineName,UserName,TimeWritten, Source, EventID,message |
        Format-Table -Wrap} -ErrorAction Stop -ErrorVariable Err |
        Out-file -FilePath C:\Users\ealbert\Desktop\Checked\SecurityErrorDetails.txt -append

        Invoke-Command -ComputerName $comps -ScriptBlock {Get-EventLog -LogName System -EntryType Error |
        Select-Object MachineName,UserName,TimeWritten, Source, EventID,message |
        Format-Table -Wrap} -ErrorAction Stop -ErrorVariable Err |
        Out-file -FilePath C:\Users\ealbert\Desktop\Checked\SystemErrorDetails.txt -append

    }
    catch {
        if($LogErrors){
            write-host "$Comps Not responding, Error Has Been Writting to a file in C:\Users\ealbert\Desktop\Checked\Error.txt"
            $Err | Out-File -FilePath C:\Users\ealbert\Desktop\Checked\Error.txt -Append
        } Else {
            Write-Output "Computers Not Responding will not be cached"
            }
        
        }
     
    }

}



#-----------------------------------------------------------GET ADCOMPUTER DATA---------------------------------------------------------------------------------------------#
function Get-UCStewardPassword {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName='Computer')]
        [String[]]$ComputerName

    )
    
    begin {}
    
    process {
            Foreach($Comps in $ComputerName){
                $a=Get-AdComputer -Identity $Comps -Properties *

                $props = @{
                    'Computer Name'=$a.Name
                    #'Members'=$a.Memberof
                    'Password Last Set'=$a.PasswordLastSet
                    'Admin Password'=$a.'ms-mcs-AdmPwd'
                    'Computer Location'=$a.Description
                }
                $obj = New-Object -TypeName psobject -Property $props
                write-output $obj
            }
        }
    
    end {}
}


#----------------------------------------------------------- Get Last LoggedOn User----------------------------------------------------------#
Function Get-UCLoggedOnUser {
    [CmdletBinding()]

    Param(
        [Parameter ()]
        [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 })]
        [ValidateNotNullorEmpty()]
        [string []] $ComputerName  = $env:COMPUTERNAME
    )

    foreach ($comp in $ComputerName){
        $output = @{ 'ComputerName' = $comp}
        $output.Username = (Get-WmiObject -Class win32_computerSystem -ComputerName $comp).Username
        [PSCustomObject]$output
    }
}

#----------------------------------------------------------- ENABLE REMOTE LOGIN TO USER ----------------------------------------------------------#
function Enable-UCRemoteLoggeOnUser{
    <#
    .DESCRIPTION
    Enable a user to remotely connect to his computer.However, this script could also be used to add users to the localgroups on a user computer.

    .EXAMPLE
    Enable-UCRemoteLoggeOnUser -ComputerName NGMXL9293LFM -GroupName "Remote Desktop Users" -UserName "JBethelite"

    #>
    [cmdletBinding ()]
    Param(
        [Parameter ()]
        [validateScript( {Test-Connection -ComputerName $_  -Quiet -Count 1} )]
        [validateNotNullorEmpty ()]
        [String[]]$ComputerName = $env:COMPUTERNAME,
        $GroupName,
        [String[]]$UserName
    )
   
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {Add-LocalGroupMember -Group $Using:GroupName -Member $Using:UserName -Verbose}  -ArgumentList $GroupName, $UserName
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-LocalGroupMember -Group $Using:GroupName -Verbose}  -ArgumentList $GroupName, $UserName

}

#----------------------------------------------------------- REMOVE REMOTE LOGIN TO USER ----------------------------------------------------------#

function Remove-UCRemoteLoggeOnUser{
    <#
    .DESCRIPTION
    Enable a user to remotely connect to his computer.However, this script could also be used to add users to the localgroups on a user computer.

    .EXAMPLE
    Enable-UCRemoteLoggeOnUser -ComputerName NGMXL9293LFM -GroupName "Remote Desktop Users" -UserName "JBethelite"

    #>
    [cmdletBinding ()]
    Param(
        [Parameter ()]
        [validateScript( {Test-Connection -ComputerName $_  -Quiet -Count 1} )]
        [validateNotNullorEmpty ()]
        [String[]]$ComputerName = $env:COMPUTERNAME,
        $GroupName,
        [String[]]$UserName
    )
   
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {Remove-LocalGroupMember -Group $Using:GroupName -Member $Using:UserName -Verbose}  -ArgumentList $GroupName, $UserName
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-LocalGroupMember -Group $Using:GroupName -Verbose}  -ArgumentList $GroupName, $UserName 

}

#----------------------------------------------------------- File-UCTransfer Cmdlet ----------------------------------------------------------#
<#
.Description
This script is designed to transfer multiple or single file from your computer to remote computer

.Example
File-UCTransfer -UserName JBethelite -ComputerName NGMXL9293DZ -Origin C:\Powershell\file.txt

The Above example send a single file to the remote computer

.Example
File-UCTransfer -UserName JBethelite -ComputerName NGMXL9293DZ -Origin C:\Powershell\File\*

The Above script transfer all the files in the File Directory. Note that transfering all content of a specific file you need to specified the (*) asterik symbol


#>
function File-UCTransfer {

    [cmdletBinding()]
    param (
        [String]
        [Parameter(Mandatory=$true)]
        $UserName,
        [ValidateScript({Test-connection -computerName $_ -Quiet -Count 1})]
        [Parameter(Mandatory=$true)]$ComputerName,
        [Parameter(Mandatory= $true)]$Origin,
        $FileDestination = "C:\users\$userName\Document" 
    )
    Begin{
        $error.Clear()
        Write-Verbose "This script will send a file to another User Desktop by default"
        $EstPSSession = New-PSSession -ComputerName $ComputerName
    }
    Process{
        #check for the existence of a file before sending it
        
        Try{
          Copy-Item -Path $Origin -Destination $FileDestination -ToSession $EstPSSession -Recurse -ErrorAction Stop -PassThru -Force
        }

        Catch [System.IO.IOException]{
            Write-Warning "The path does not exist."            
        }
    }
    End{
            Write-Host "Your File has been sent to the Desktop of the user '$FileDestination'" -BackgroundColor Black -ForegroundColor Green
            Get-PSSession | Remove-PSSession

    }
    
}

#-------------------------------------------------------------------Uninstalled-WindowsApps Function-------------------------------------------------
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
                                     Write-Host "WindpwsApp Store not found"
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
                 } #****************end try/catch Error***************
               
                }   Else{
                      Write-Host $error[0].exception -ForegroundColor Red
                        $Comp | Out-File $CSVExport\WinRMError.csv -Append
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

#---------------------------------------------------------Rename-UCUserProfile.ps1 and Revert-UCUserProfile.ps1-------------------------#

#Welcome to registry file 
function Rename-UCUserProfile{
<#
.SYNOPSIS
Renaming user profile for troubleshooting purpose

.DESCRIPTION
This cmdlet allow a technician to rename a user profile to .old for troubleshooting purpose. 

.EXAMPLE
Rename-UCUserProfile -ComputerName NGMXL9293LDM

The above line accept computer as a parameter. 
#>

[cmdletbinding()]
param(
    [Parameter(Mandatory = $true)] $ComputerName = 'Localhost'
    #[Parameter(Mandatory = $true)] $UserName
)

Begin{
Clear-Host
Write-Host "WELCOME: SELECT A NUMBER FOR THE USERNAME BELOW" -ForegroundColor Green
}
Process{
Try{
    Invoke-Command -ComputerName $ComputerName -ScriptBlock{
    $UserProfileCollection = [System.Collections.ArrayList]@()
    $AllUsers = (Get-ChildItem -Path C:\Users\).Name
    ForEach($User in $AllUsers){
        $ArrayVal = $UserProfileCollection.Add($User)
        Write-Host "$ArrayVal) $User"
        }
    $UserPrompt = Read-Host
    $userVal = $UserProfileCollection[$UserPrompt]
    Write-Host "$UserVal has Been Selected."
    Write-Host "Processing. . ."
    Start-Sleep -Seconds 3 
    Rename-Item -Path C:\Users\$userVal -NewName "$userVal.OLD" -Force -PassThru
    Write-Warning "Username '$UserVal' has been renamed to $UserVal.OLD"

    #Renaming the User Profile in Registry
    [string]$USERSID = (Get-CimInstance -ClassName Win32_UserProfile |
    Where-Object {$_.LocalPath -like "*C:\users\$userVal*"}).SID
    Write-Output $USERSID

    Get-Item -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$USERSID" |
    Rename-Item -NewName "$USERSID.OLD" -Force -PassThru
    }
}
Catch [System.Management.Automation.Remoting.PSRemotingTransportException] {
    Write-Warning "$ComputerName is Currently Not Online"
} 
Catch {Write-Warning "An Error has Occured. Check and try again"}
    
}
End{}
}
function Revert-UCUserProfile{
<#
.SYNOPSIS
Reverting the user profile to the correct username. Example Jbethelite.OLD to Jbethelite

.DESCRIPTION
This cmdlet allow a technician to revert a change his has made to a user profile. 

.EXAMPLE
Revert-UCUserProfile -ComputerName NGMXL9293LDM

The above line accept computer as a parameter. 
#>
[cmdletbinding()]
param(
    [Parameter(Mandatory = $true)] $ComputerName = 'Localhost'   
)
Begin{
Clear-Host
Write-Host "WELCOME: TO REVERT YOUR CHANGES, SELECT A NUMBER FOR THE USERNAME" -ForegroundColor Green
}
Process{
Invoke-Command -ComputerName $ComputerName -ScriptBlock{
    $UserProfileCollection = [System.Collections.ArrayList]@()
    $ContentVals = [System.Collections.ArrayList]@()
    $AllUsers = (Get-ChildItem -Path C:\Users\).Name
    ForEach($User in $AllUsers){
        $ArrayVal = $UserProfileCollection.Add($User)
        Write-Host "$ArrayVal) $User"
        }
    $UserPrompt = Read-Host
    $userVal = $UserProfileCollection[$UserPrompt]
    Write-Host "$UserVal has Been Selected."
    Write-Host "Processing. . ."
    Start-Sleep -Seconds 3

    $USERNAME = Read-Host "RETYPE USERNAME AGAIN WITHOUT .OLD FOR COMFIRMATION"
    Rename-Item -Path C:\Users\$UserVal -NewName $USERNAME -Force -PassThru
    Write-Warning "Username '$UserVal' has been renamed to '$USERNAME'"
    #Renaming the User Profile in Registry
    [string]$USERSID = (Get-CimInstance -ClassName Win32_UserProfile |
    Where-Object {$_.LocalPath -like "*C:\users\$USERNAME*"}).SID
    "`n"
    Write-Host "THE $USERVAL SID IS '$USERSID'" -ForegroundColor DarkYellow
    "`n"
    $RenameUserSID = Read-Host "COPY THE ABOVE USER SID AND PASTE TO RENAME REGISTRY HIVE WITHOUT THE '.OLD'"
    Get-Item -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$USERSID" |
    Rename-Item -NewName "$RenameUserSID" -Force -PassThru

  }
}
End{
    Write-warning "To delete a User profile(s) from any remote Computer, please use the Scripted Support Tool (SST) Cmdlet called Remove-UserProfile"
    }
}


#-----------------------------------Windows Defender Clients Updates---------------------------------------------
Function Update-UCWindowsDefender1 {
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
