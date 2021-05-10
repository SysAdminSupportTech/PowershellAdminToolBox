function Wait-KeyPress{
    param(
        [String]
        $Message = 'Press Arrow-Down to continue',

        [ConsoleKey]
        $Key = [ConsoleKey]::DownArrow
    )
    Write-Host -Object $Message -ForegroundColor Yellow -BackgroundColor Black
    do{
        if([Console]::KeyAvailable){}
        $KeyInfo = [Console]::ReadKey($false)
    } until($KeyInfo.Key -eq $Key)
}

'First Part'
Wait-KeyPress
'Second Part'