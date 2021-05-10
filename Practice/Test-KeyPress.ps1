Function Test-KeyPress{
    param(
        #Submit the key want to detect
        [Parameter(Mandatory)]
        [ConsoleKey]
        $Key,

        [System.ConsoleModifiers]
        $ModifierKey = 0
    )
    if([Console]::KeyAvailable){
        $PressedKey = [Console]::ReadKey($true)

        $isPressedKey = $key -eq $pressedKey.key
        if ($isPresssedKey){
            $PressedKey.Modifiers -eq $ModifierKey
        } Else {
            [Console]::Beep(1800, 200)
            $false
        }
    }
}

function Modifier{
    Write-Warning 'Press Ctrl+Shift+K to exit monitoring!'

do
{
    Write-Host '.' -NoNewline
    $pressed = Test-KeyPress -Key K -ModifierKey 'Control,Shift'
    if ($pressed) { break }
    Start-Sleep -Seconds 1
} while ($true)
}
