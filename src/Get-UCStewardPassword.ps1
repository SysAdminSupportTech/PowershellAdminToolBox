function Get-UCAdCompData {
    [CmdletBinding()]
    param (
        [Parameter (Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName='Computer')]
        [String[]]$ComputerName

    )
    
    begin {}
    
    process {
            Foreach($Comps in $ComputerName){
                $a=Get-AdComputer -Identity $Comps -Properties *

                $props = @{
                    'Computer Name'=$a.Name
                    #'Members'=$a.Memberof
                    'Password Last Set'=$a.PasswordLastSet
                    'Admin Password'=$a.'ms-mcs-AdmPwd'
                    'Computer Location'=$a.Description
                }
                $obj = New-Object -TypeName psobject -Property $props
                write-output $obj
            }
        }
    
    end {}
}