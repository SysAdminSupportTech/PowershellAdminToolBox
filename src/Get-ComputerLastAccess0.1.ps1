Function Get-ComputerFromDepartment{
    param(
        [Parameter(mandatory = $true)]
        [int]$AccessDate,
        [Parameter(Mandatory = $true)]
        [string]$ExportCSV = "C:\temps",
        [string[]]$DepartmentName
    )
    $deptArray = [System.Collections.ArrayList]@()
            $ADGroupMembers = (Get-ADGroup -Filter { Name -like "NGA-Client-*" } -SearchBase 'OU=Groups,OU=NGA,DC=bethel,DC=jw,DC=org').Name
            ForEach ($deptGroup in $ADGroupMembers) {
                #adding groups name in an array
                $DeptArrayVal = $deptArray.Add($deptGroup)
                if ($deptGroup -like "*$DepartmentName*") {
                    "$DeptArrayVal.  $deptGroup"
                }    
            }
            $DeptSelection = Read-Host "ENTER NUMBER OF THE ADGROUP"
            $DeptSelect = $deptArray[$DeptSelection]
            ForEach ($Device in $DeptSelect) {
                $ADGroupDevice = (Get-ADGroupMember -Identity $Device -Recursive).Name
                ForEach ($comp in $ADGroupDevice) {
                    Get-ADComputer -Identity $Comp -Properties * | Select-Object Name, lastlogOnDate, Description | Where-Object { $_.lastlogOnDate -like "*$ComputerLastAccess*" } 
                    Get-ADComputer -Identity $Comp -Properties * |
                    Where-Object { $_.lastlogOnDate -like "*$ComputerLastAccess*" } |
                    Export-Csv -Path $ExportCSV\ComputerLastAccess.csv -Append -NoTypeInformation
         }
     }
}
function Get-ComputerFromOU{
    param(
        [Parameter(Mandatory = $true)][String]$DepartmentName,
        [Parameter(Mandatory = $true)][string]$ExportCSV
    )
    Begin{}
    Process{
        $EndDate = Get-Date -DisplayHint Date
        $deptArray = [System.Collections.ArrayList]@()
            $ADGroupMembers = (Get-ADGroup -Filter { Name -like "NGA-Client-*" } -SearchBase 'OU=Groups,OU=NGA,DC=bethel,DC=jw,DC=org').Name
            ForEach ($deptGroup in $ADGroupMembers) {
                #adding groups name in an array
                $DeptArrayVal = $deptArray.Add($deptGroup)
                if ($deptGroup -like "*$DepartmentName*") {
                    "$DeptArrayVal.  $deptGroup"
                }    
            }
            $DeptSelection = Read-Host "ENTER NUMBER OF THE ADGROUP"
            $DeptSelect = $deptArray[$DeptSelection]
            Write-Output $DeptSelect
            ForEach ($Device in $DeptSelect) {
                $ADGroupDevice = (Get-ADGroupMember -Identity $Device -Recursive).Name
                ForEach ($comp in $ADGroupDevice) {
                    $LogonDate = (Get-ADComputer -Identity $Comp -Properties *).lastlogOnDate
                    $StartDate = $LogonDate.ToString("MM/dd/yyyy")
                    $DaysLogOn = (New-TimeSpan -Start $StartDate -End $EndDate).Days
                    Get-ADComputer -Identity $Comp -Properties * | Select-Object Name, lastlogOnDate, Description, @{Name = 'Last Heartbeat'; e={$DaysLogOn}}
                    Get-ADComputer -Identity $Comp -Properties * | Select-Object Name, lastlogOnDate, Description, @{Name = 'Last HeartBeat'; e={$DaysLogOn}} |
                    Export-Csv -Path $ExportCSV\computerLastLogOnInfo_$DeptSelect.csv -Append -NoTypeInformation

                }
            }
    }
    End{}
}
function Get-ComputerFromCSVFile{
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExportFile,
        [string]$ImportFile
    )
    $EndDate = Get-Date -DisplayHint Date
    $contents = (Import-Csv -Path $ImportFile).Name
    ForEach($comp in $contents){
        $LogonDate = (Get-ADComputer -Identity $comp -Properties *).lastlogOnDate
        $StartDate = $LogonDate.ToString("MM/dd/yyyy")
        $DaysLogOn = (New-TimeSpan -Start $StartDate -End $EndDate).Days
        Get-ADComputer -Identity $Comp -Properties * | Select-Object Name, lastlogOnDate, Description, @{Name = 'Last Heartbeat'; e={$DaysLogOn}}
        Get-ADComputer -Identity $Comp -Properties * | Select-Object Name, lastlogOnDate, Description, @{Name = 'Last HeartBeat'; e={$DaysLogOn}} |
        Export-Csv -Path $ExportFile\computerLastLogOnInfo.csv -Append -NoTypeInformation
     }
}
Function Get-ComputerLastAccessDate{
    Clear-Host
    $userChoice = Read-Host "Get Computer Last Access Date: D: Department, F: CSV File" -ForegroundColor Green
    switch($userChoice){
        D{Get-ComputerFromOU}
        F{Get-ComputerFromCSVFile}
    }
}