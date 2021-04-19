<#
.SYNOPSIS
Get all computers that are currently connected to the domain and export these computers to a CSV file
#>
function Ping-UCTestComputerOnlineStatusFromFile{
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
            Write-Host $Comp "Alive"
            $comp | Out-File $CSVExport\ComputerOnline.csv -Append
         }Else{
            Write-Host $Comp "Not Alive"
            $comp | Out-File $CSVExport\ComputerNotResponding.csv -Append

         }
        }
    }
 }   

function Ping-UCTestComputerOnlineStatusFromADGroup{
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
                Write-output "$computer Not online"
                $computer | Out-File "$SaveFilePath\ComputerNotOnline.csv" -Append

            }
        }
    }Else {
       Write-Warning "The Path you specified does not exit. Please check again"
    }  
}
