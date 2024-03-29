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
        $UserPrompt = Read-Host "Enter Number"
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