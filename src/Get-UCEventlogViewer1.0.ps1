Function Get-UCEventLogViewer {
[cmdletbinding()]
param(
    $ADGroup,
    $SaveFilePath
)
    Get-UCTestComputerOnlineStatusFromADGroup -ADGroup $ADGroup -SaveFilePath $SaveFilePath
    Get-UCEventLog -ADGroup $ADGroup -FileDestination $SaveFilePath
}

#Ping Computer states
function Get-UCTestComputerOnlineStatusFromADGroup{
    [cmdletbinding ()]

    param(  
       [parameter(Mandatory=$true)]
       $ADGroup,
       
       [string]$SaveFilePath = ''
    )
    if(Test-Path -Path $SaveFilePath){
        $AdComputers = Get-ADGroupMember -Identity $ADGroup -Recursive | Select-Object -ExpandProperty Name

        ForEach($computer in $AdComputers) {
        $connection_Est = Test-Connection -ComputerName $computer -Count 1 -Quiet
            if($connection_Est){
                Write-Output "$computer Status: Online"
                $computer | Out-File "$SaveFilePath\ComputerOnline.csv" -Append
        
           }Else{
                Write-output "$computer Status: Offline"
                $computer | Out-File "$SaveFilePath\ComputerNotOnline.csv" -Append

            }
        }
    }Else {
       Write-Warning "The Path you specified does not exit. Please check again"
    }  
}

#Get BitlockerEncryption Status
Function Get-UCEventLog{
    [cmdletbinding()]

    param(
        [Parameter(Mandatory=$true)]
        [String]$ADGroup = '',

        [Parameter(Mandatory=$true)]
        [String]$FileDestination = '',

        $StartDate = '',
        $EndDate = ''
    )

    Begin{
        #Preparing an Excel spreadsheet to write data to

            if(Test-Path -Path $FileDestination\DataLogBook){
               Write-Progress "Computer Environment is Configured. Task Sequence Continue..."

            } Else {
                #Creating a Folder Structure
                New-Item -Path $FileDestination -Name DataLogBook -ItemType Directory
                New-item -Path $FileDestination\DataLogBook\Application -ItemType Directory
                New-Item -Path $FileDestination\DataLogBook\Security -ItemType Directory
                New-Item -Path $FileDestination\DataLogBook\Systems -ItemType Directory
            }
    }

    Process{
               
        #Get All Event on the users computer
        $logs = Get-EventLog -LogName * -Newest 3 |
        Where-Object {$_. Log -like "*Application" -or $_. Log -like "*security" -or $_. Log -like "*system"} |
        Select-Object -ExpandProperty Log

        Write-Output "Collecting all Logs of computers in $ADGroup"
        #Creating a datalogBook from existing template name with date format
        $date = (Get-Date -Format "MM/dd/yy").Replace('/','') 
        $usrinput = Read-Host "Do you want to get all the logs on this computer(Y/N)"    
        $ComputerOnline = Get-Content -Path $FileDestination\computerOnline.csv


        Foreach ($log in $Logs){
        if ($usrinput -eq "N"){
                if ($log -eq "Application"){
                        [string]$startDate = Read-Host "Enter your start Date(mm/dd/yyyy)"
                        [string]$EndDate = Read-Host "Enter the End Date (mm/dd/yyyy)"

                        Foreach ($computer in $ComputerOnline){
                        Write-Progress -Activity "Collecting $computer Logs" -Status "$computer in Progress"
                        Invoke-Command -ComputerName $computer -ScriptBlock {Get-EventLog -LogName Application -EntryType Error, Warning -After $Using:StartDate -Before $Using:EndDate |
                        Select-Object EventID, UserName, TimeGenerated, TimeWritten, Message, Source, EntryType, PScomputerName
                        } -ArgumentList $StartDate, $EndDate |
                        Export-Csv -Path $FileDestination\DatalogBook\Application\$date'_'DataLogBook.csv -Append -NoTypeInformation

                        }  
                     } Elseif($Log -eq "Security"){
                        Foreach ($computer in $ComputerOnline){
                        Invoke-Command -ComputerName $computer -ScriptBlock {Get-EventLog -LogName Security -After $Using:StartDate -Before $Using:EndDate |
                        Select-Object EventID, UserName, TimeGenerated, TimeWritten, Message, Source, EntryType, PScomputerName
                        } -ArgumentList $StartDate, $EndDate |
                        Export-Csv -Path $FileDestination\DatalogBook\Security\$date'_'DataLogBook.csv -Append -NoTypeInformation

                        }
                     } Else{
                        Foreach ($computer in $ComputerOnline){
                        Invoke-Command -ComputerName $computer -ScriptBlock {Get-EventLog -LogName system -EntryType Error, Warning -After $Using:StartDate -Before $Using:EndDate |
                        Select-Object EventID, UserName, TimeGenerated, TimeWritten, Message, Source, EntryType, PScomputerName
                        } -ArgumentList $StartDate, $EndDate |
                        Export-Csv -Path $FileDestination\DatalogBook\Systems\$date'_'DataLogBook.csv -Append -NoTypeInformation

                        }
                     }
            } Else {
                     if ($log -eq "Application"){
                        
                        Foreach ($computer in $ComputerOnline){
                        Write-Progress -Activity "Collecting $computer Logs" -Status "$computer in Progress"
                        Invoke-Command -ComputerName $computer -ScriptBlock {Get-EventLog -LogName Application -EntryType Error, Warning |
                        Select-Object EventID, UserName, TimeGenerated, TimeWritten, Message, Source, EntryType, PScomputerName
                        } |
                        Export-Csv -Path $FileDestination\DatalogBook\Application\$date'_'DataLogBook.csv -Append -NoTypeInformation

                        }  
                     } Elseif($Log -eq "Security"){
                        Foreach ($computer in $ComputerOnline){
                        Invoke-Command -ComputerName $computer -ScriptBlock {Get-EventLog -LogName Security|
                        Select-Object EventID, UserName, TimeGenerated, TimeWritten, Message, Source, EntryType, PScomputerName
                        } |
                        Export-Csv -Path $FileDestination\DatalogBook\Security\$date'_'DataLogBook.csv -Append -NoTypeInformation

                        }
                     } Else{
                        Foreach ($computer in $ComputerOnline){
                        Invoke-Command -ComputerName $computer -ScriptBlock {Get-EventLog -LogName system -EntryType Error, Warning |
                        Select-Object EventID, UserName, TimeGenerated, TimeWritten, Message, Source, EntryType, PScomputerName
                        } |
                        Export-Csv -Path $FileDestination\DatalogBook\Systems\$date'_'DataLogBook.csv -Append -NoTypeInformation

                        }
                     }
            }
            
        } 
    }
    End{
        Write-Output "All Event Logs for the computers in $ADGroup has been collected to the path: $saveFilePath"
    }
}
    