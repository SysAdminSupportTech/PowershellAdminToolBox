function Enable-UCRemoteLoggeOnUser{
    <#
    .DESCRIPTION
    Enable a user to remotely connect to his computer.However, this script could also be used to add users to the localgroups on a user computer.

    .EXAMPLE
    Enable-UCRemoteLoggeOnUser -ComputerName NGMXL9293LFM -GroupName "Remote Desktop Users" -UserName "JBethelite"

    #>
    [cmdletBinding ()]
    Param(
        [Parameter ()]
        [validateScript( {Test-Connection -ComputerName $_  -Quiet -Count 1} )]
        [validateNotNullorEmpty ()]
        [String[]]$ComputerName = $env:COMPUTERNAME,
        $GroupName,
        [String[]]$UserName
    )
   
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {Add-LocalGroupMember -Group $Using:GroupName -Member $Using:UserName -Verbose}  -ArgumentList $GroupName, $UserName
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {Get-LocalGroupMember -Group $Using:GroupName -Verbose}  -ArgumentList $GroupName, $UserName

}
