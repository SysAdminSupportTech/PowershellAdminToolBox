do {

    if ([Console]::KeyAvailable){
        $KeyInfo = [Console]::ReadKey($True)
        Break
    }

    Write-Host '.' -NoNewline
    Start-Sleep -Seconds 1
} While ($true)
    Write-Host
    $KeyInfo
