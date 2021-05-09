

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
function Get-UCAdCompData {
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
          Invoke-Command -ComputerName $ComputerName -ScriptBlock{New-Item -Path $Using:FileDestination -Name UCTransfer -ItemType Directory -ErrorAction SilentlyContinue} -ArgumentList $FileDestination
          Copy-Item -Path $Origin -Destination $FileDestination\UCTransfer -ToSession $EstPSSession -Recurse -ErrorAction Stop
        }

        Catch [System.IO.IOException]{
            Write-Warning "The path does not exist."            
        }
    }
    End{
            Write-Host "Your File has been sent to the Desktop of the user '$FileDestination'" -BackgroundColor Black -ForegroundColor DarkGreen
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

#--------------------------------------Ping computers from ADGroup or from CSV file --------------------------------------
function Ping-UCTestComputerOnlineStatusFromFile{
<#
.DESCRIPTION
This cmdlet command ping all the computers in a csv file and output computers responding and not responding to the
file path specified by the user.
 
.EXAMPLE
1. Ping computers in a file 

Ping-UCTestComputerOnlineStatusFromFile -CSVPath C:\users\userpath\file.csv -saveFilePath C:\users\Userpath\

NOTE: the [-saveFilePathe] accept path as an argument without the file name.

.EXAMPLE

2. Ping computers in a file and export those responding on the network to csv file

Ping-UCTestComputerOnlineStatusFromFile -CSVPath C:\users\userpath\file.csv -$SaveFilePath C:\user\userpath\
NOTE: the [-saveFilePathe] accept path as an argument without the file name.
#>
    [cmdletbinding ()]

    param( 
       [parameter(Mandatory=$true)]
       [string]$CSVPath,
       $SaveFilePath
    )
      Process{
      $Computer = (Import-Csv -Path $CSVPath).ComputerName 
      ForEach($Comp in $Computer){
         $compStatus = Test-Connection -ComputerName $Comp -Count 1 -Quiet -ErrorAction Stop
         if($compStatus){
            Write-Host $Comp "Online"
            $comp | Out-File $CSVExport\ComputerOnline.csv -Append
         }Else{
            Write-Host $Comp "offline"
            $comp | Out-File $CSVExport\ComputerNotResponding.csv -Append

         }
        }
    }
 }   

function Ping-UCTestComputerOnlineStatusFromADGroup{
<#
.SYNOPSIS
Get all computers that are currently connected to the domain and export these computers to a CSV file

.DESCRIPTION
This cmdlet test the status of computers if they are currently online or not. 

.EXAMPLE

Ping computers in a specific ADgroup

Ping-UCTestComputerOnlineStatusFromADGroup -ADGroup "NGA-CLIENT-CD" -SaveFilePath C:\Powershell\ucmodule

NOTE: the [-saveFilePathe] accept path as an argument without the file name.
#>
    [cmdletbinding ()]

    param(  
       [parameter(Mandatory=$true)]
       $ADGroup,
       
       [string][parameter(Mandatory = $true)]$SaveFilePath = ''
    )
    if(Test-Path -Path $SaveFilePath){
        $AdComputers = Get-ADGroupMember -Identity $ADGroup -Recursive | Select-Object -ExpandProperty Name

        ForEach($computer in $AdComputers) {
        $connection_Est = Test-Connection -ComputerName $computer -Count 1 -Quiet
            if($connection_Est){
                Write-Output "$computer Status: Online"
                $computer | Out-File "$SaveFilePath\ComputerOnline.csv" -Append
        
           }Else{
                Write-output "$computer offline"
                $computer | Out-File "$SaveFilePath\ComputerNotOnline.csv" -Append

            }
        }
    }Else {
       Write-Warning "The Path you specified does not exit. Please check again"
    }  
}
