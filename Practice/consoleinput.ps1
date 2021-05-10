#Welcome to our keylogger Value
Do{
    if([Console]::KeyAvailable){
        $keystroke  = [Console]::ReadKey($true)
        break
    }
Write-Host "You Must press a key o"
Start-Sleep 2
} while ($true)

$keystroke