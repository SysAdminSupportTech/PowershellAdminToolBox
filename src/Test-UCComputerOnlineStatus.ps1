
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
