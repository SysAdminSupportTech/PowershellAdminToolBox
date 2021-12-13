function Set-UCLocalAccountExpire{
    [cmdletbinding()]
    param(
        [string][Parameter(Mandatory = $True)]$UserAccount,
        [datetime]$UCDateExpires
    )
    #Check if $userAccount is empty
    $ConfirmLocalAccount = Get-localuser -Name $UserAccount
    if($ConfirmLocalAccount){
       Set-LocalUser -Name $UserAccount -AccountExpires $UCDateExpires
       $Message = (Get-LocalUser -Name $UserAccount).AccountExpires
       Write-Host "This Account Will Expire on: $Message" -ForegroundColor Green
       Write-Host "NOTE: Kindly let your user know of this information"
    } Else {
        Write-Host "User Account Select Does not Exist"
    }   
}

Function New-UCLocalUser{
    [cmdletbinding()]
    param(
        [string][Parameter(Mandatory = $True)]$UserName,
        $LocalAccountGroup,
        [switch]$UCDateExpires
    )
    #Get All local groups on the computer and allow the user to select which of the group to add the new user
    $localGrouplist = [System.Collections.ArrayList]@()
    $GetLocalGroup = (Get-LocalGroup).Name

    #iterate over the local groups
    ForEach($group in $GetLocalGroup){
        #append groups to LocalGroupList
        $New_ArrayList = $localGrouplist.Add($group)
        Write-Host "$New_ArrayList). $group"
    }
    Write-Host "Select a Number to Add User to a Group: " -ForegroundColor Yellow -NoNewline
    $UserPrompt = Read-Host 
    $LocalAccountGroup = $localGrouplist[$UserPrompt] 
    
    #Creating the New User Account
    Write-Host "Create New Password: " -ForegroundColor yellow -NoNewline
    $password = Read-Host -AsSecureString
    New-LocalUser -Name $UserName -Password $password | Add-LocalGroupMember -Group $LocalAccountGroup

    #If user may change password at next logon
    Write-Host "Do You Want User to Change Password at Next Logon (y/n):" -ForegroundColor yellow -NoNewline
    $UserMayChangePassword = Read-Host 
    switch($UserMayChangePassword){
        y{  
            Clear-Host
            Net user $UserName /logonPasswordChg:yes
            Write-Host "Account Created Successfully" -ForegroundColor Green
            Write-Host "Account Name: $UserName"
            Write-Host "Group Member: $LocalAccountGroup"
            Write-Host "User Will be required to change password at next logon"
        }
        N{
            Clear-Host
            Write-Host "Account Created Successfully" -ForegroundColor Green
            Write-Host "Account Name: $UserName"
            Write-Host "Group Member: $LocalAccountGroup"
            Write-Host "NOTE: User Will Make use of the Default Password created. Please inform the user"
        }
    }
}
#Start the script
Clear-Host
Write-Host "Welcom To Set-UCAccountSetup"
Write-Host "1. Create Account"
Write-Host "2. Set Account Expires Date"
Write-Host "Select Option: " -ForegroundColor Yellow -NoNewline
$userChoiceSelect = Read-Host
switch ($userChoiceSelect){
    1{
        Write-host "You Want to Create a New Account" -ForegroundColor Green
        Start-Sleep -Seconds 3
        New-UCLocalUser -UserName (Read-Host "Enter Username")
    }
    2{
        Write-host "You Want to Set Account Expiration Date" -ForegroundColor Green
        Set-UCLocalAccountExpire -UserAccount (Read-Host "Enter User Name") -UCDateExpires (Read-Host "Enter Date in (MM/dd/yyyy)")
    }
}