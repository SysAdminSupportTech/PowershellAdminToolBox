Function Uninstall-UCBlackListedApp {
    [cmdletbinding()]
    param()

    Begin{
        #Setting WindowsApp Permission folder to the local user account
        $LocalUser = $env:HOMEPATH.Split("\") #Split user home directory path into array
        $localuserName = $localuser[2] #Array indexing to get the user name
        
        Get-Acl -Path C:\

    }
    Process{
        $Apps = @("Spotify","whatsApp") #Arrays of application
        #ForEach($App in $Apps){
           # Get-ChildItem -Path "C:\Program Files\WindowsApps" -Force

        }
    }
    End{}
}