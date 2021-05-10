# valid key names can be ASCII codes:
$key = [Byte][Char]'A'    
    
# this is the c# definition of a static Windows API method:
$Signature = @'
    [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
    public static extern short GetAsyncKeyState(int virtualKeyCode); 
'@

# Add-Type compiles the source code and adds the type [PsOneApi.Keyboard]:
Add-Type -MemberDefinition $Signature -Name Keyboard -Namespace PsOneApi
    
Write-Host "Press A within the next second!"
Start-Sleep -Seconds 1

# the public static method GetAsyncKeyState() is now availabe from
# within PowerShell and tests whether the key is pressed.
# Actually, one bit is reporting whether the key is pressed,
# and the result is always either 0 or 1, which can easily
# be converted to bool:
$result = [bool]([PsOneApi.Keyboard]::GetAsyncKeyState($key) -eq -32767)
$result