function Get-UCComputerLastLogOnFromCSVFile{
    <#
    .DESCRIPTION
    This script generate all the last logon date of computers in a .csv file
    .Example
    Get-UCDeptComputerLastLogOnDate -importfile C:\temp\file.csv -ExportCSV C:\temp\
    .PARAMETER importfile
    DepartmentName: Specified the document you want to import computers from.
    .PARAMETER ExportFile
    ExportCSV: Specified the directory path without the name of the file
    #>
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