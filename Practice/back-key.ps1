Function Navigation{

  param(
    [String]
    $Message = "Enter 'B' to Go Back..."

  )
 Add-Type -AssemblyName WindowsBase
 Add-Type -AssemblyName PresentationCore 
 $Key = [System.Windows.Input.Key]::B

 Write-Output -InputObject $Message
 Do{
    $BackKey = [System.Windows.Input.Keyboard]::IsKeyDown($key)
    if($BackKey){
        Write-Output "Back Key has been seleted"
        Pop-Location
        Write-Host "you are currently working on " -nonew
        Get-Location
    }
    Write-Host "." -NoNewline
    Start-Sleep -Milliseconds 120
 }while($BackKey -ne $Key)

}
Navigation
