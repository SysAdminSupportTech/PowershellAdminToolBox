function Get-UCDeptComputerLastLogOnDate{
    <#
    .DESCRIPTION
    This script generate all the last logon date in a department
    .Example
    Get-UCDeptComputerLastLogOnDate -DepartmentName legal -ExportCSV C:\temp\
    .PARAMETER departmentName
    DepartmentName: Specified the department your are working on
    .PARAMETER ExportCSV
    ExportCSV: Specified the directory path without the name of the file
    #>
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