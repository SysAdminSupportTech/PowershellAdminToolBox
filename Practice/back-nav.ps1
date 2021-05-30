function Back-Nav {
    param(
    [String]
    $Message = "Press Windows Down Key to Continue",

    [Consolekey]
    $Key = [ConsoleKey]::End
    )

    Write-Host -Object $Message -ForegroundColor Yellow -BackgroundColor Black
    do{
        if([Console]::KeyAvailable){
            $KeyInfo = [Console]::Readkey($false)
        }
        Write-Host "." -NoNewline
        Start-Sleep -Milliseconds 120
    }
    while($KeyInfo.key -ne $Key)
    $key
    $KeyInfo
}

Function Nav-Key {
    Add-Type -AssemblyName WindowsBase
    Add-Type -AssemblyName PresentationCore

    #Selecting the key input
    $key = [System.Windows.Input.Key]::A

    Do{
        $isCtrl = [System.Windows.Input.Keyboard]::IsKeyDown($key)
        if($isCtrl){
            Write-Host "yOu enter the correct Key" -ForegroundColor Green
            break
        }
        Write-Host "." -NoNewline
        Start-Sleep -Milliseconds 120
    }
    while($true)
    $key
}
