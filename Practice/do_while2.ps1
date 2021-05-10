start-process notepad

$p = "notepad"

Do

{

 "$p found at $(get-date)"

 $proc = Get-Process

 start-sleep 2

} While ($proc.name -contains 'notepad') 