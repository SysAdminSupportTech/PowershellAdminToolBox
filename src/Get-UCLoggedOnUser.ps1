Function Get-UCLoggedOnUser {
    [CmdletBinding()]

    Param(
        [Parameter ()]
        [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 })]
        [ValidateNotNullorEmpty()]
        [string []] $ComputerName  = $env:COMPUTERNAME
    )

    foreach ($comp in $ComputerName){
        $output = @{ 'ComputerName' = $comp}
        $output.Username = (Get-WmiObject -Class win32_computerSystem -ComputerName $comp).Username
        [PSCustomObject]$output
    }
}