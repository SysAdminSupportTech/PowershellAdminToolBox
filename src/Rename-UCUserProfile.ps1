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
        $UserPrompt = Read-Host "Select Number"
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