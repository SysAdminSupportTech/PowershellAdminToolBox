<#
Write-Host "Numbers of argument : " ($args.length)
Write-Output "And they are:"
foreach($arg in $args){
    Write-Output $arg
} #>

param(
[Parameter(Mandatory = $true, Position = 1, valueFromPipeline=$true)]$Name,
[Parameter(Mandatory =$true, Position = 2, ValueFromPipeLine = $true)]$LastName)

Write-Output $Name, $LastName


