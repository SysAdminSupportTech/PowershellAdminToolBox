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
            Write-Warning "An item with the specified name C:\users\lbarrah\Document\UCTransfer already exists."            
        }
    }
    End{
            Write-Host "Your File has been sent to the Desktop of the user '$FileDestination'" -BackgroundColor Black -ForegroundColor DarkGreen
            Get-PSSession | Remove-PSSession

    }
    
}