<#Install-Module MusicPlayer -Verbose -Scope CurrentUser
    Set-ExecutionPolicy RemoteSigned
    Import-Module MusicPlayer -Verbose
    HOW TO RUN THIS SCRIPT 
        1. Ensure that the myConfig.txt is at the parent folder for Playlist directory
        2. Ensure that the script (.ps1) is at the parent folder of the Playlist directory
        3. Run the script from the location described in Point 1 & 2 above
    PLEASE NOTE:
        1. This script assumes that a media file(s) exists in the relevant directory. Desired result will not be achieved otherwise
        2. This script assumes that no media file will be less than 500KB in size.
        3. Most errors are cleared by restarting the script. Other unexpected errors should be reported 
    SAMPLE OF myConfig.txt
        Default Configuration:
        PlaylistHostFolder=C:\Users\USER\Projects\Music
        Current Configuration:
        #First='9:00:00 AM'
       #Second='10:30:00 AM'
        #Third='19:31:00 PM'
        #Fourth='20:30:00 PM'
        #Fifth='01:44:00 PM'
        #Sixth='07:00:00 PM'
        #Seventh='10:00:00 PM'
        #Eighth='11:55:00 PM'
#>
$ErrorActionPreference='stop'

function Start-Program{ 
    Write-Host "Press 1 to start regular program"
    Write-Host "Press 2 to play a special program"
    Write-Host "Press 3 to play for day of week"
    Write-Host "Press 4 to set up default folders for this program"
    Write-Host "Press 5 to edit myConfig.txt file"
    $myOption = Read-Host -Prompt "Select an option"
    $strPlaylistFolder = Get-ConfigurationFile
    switch ($myOption)
     {
           '1' {
                Play-Sound $strPlaylistFolder
           } '2' {
                Play-SpecialProgram $strPlaylistFolder
           } '3'{
                Play-ForDaysOfWeek $strPlaylistFolder
           }
             '4' {
                Prepare-Folders
           }
             '5' {
                Edit-ConfigFile $strPlayListFolder
           }
      }    
}

function Get-ConfigurationFile{
   
    $myConfig = get-content -path $strConfigGlobal
    $strPlayListParentDir = ""
    $myConfig | ForEach-Object {
        if ($_ -like 'PlaylistHostFolder*') {
            [string]$strPlayListParentDir = $_
            $strPlayListParentDir = $strPlayListParentDir.replace('PlaylistHostFolder=','')
        }
        # this function does more than just get the location of myconfig.txt. It also 
        # check to make sure that all appropriate folders (i.e. #xxxxxxxx) listed in myconfig.txt
        # are created.
        if($_ -like '#*'){
            $strThisFolder = $_.Substring(1,($_.IndexOf("=")-1))
         }
        #create it if folder does not exist
            if(-not (Test-Path ($strPlayListParentDir + ("\Playlist\" + $strThisFolder)))) {
                New-Item -Path ($strPlayListParentDir + ("\Playlist\" + $strThisFolder)) -ItemType "directory"
            cls
            }
        }
       #make sure that myConfig.txt is read only so it is not accidentally edited
       Set-ItemProperty -Path ($strPlayListParentDir + '\Playlist\myConfig.txt') -Name IsReadOnly -Value $true
    return $strPlayListParentDir
}

function Refresh-Configuration{
    $myConfig = get-content -path $strConfigGlobal
    $arAllFoldersAndTimes = @()
    $myConfig | ForEach-Object {     
        if($_ -like '#*'){
            $arAllFoldersAndTimes += $_
        }
    }
    return $arAllFoldersAndTimes
}

function Edit-ConfigFile{
    param(
        [string] $FullPathToSoundFiles= 'c:\users\user\projects\music' #--this part is the default. Can be overwritten by the parameter passed from the calling function
     )
     $strName = ""
     $strFile = ($FullPathToSoundFiles + "\Playlist\myConfig.txt")
     if( ![System.IO.File]::Exists($strFile)){
        Write-Host ($strFile + ' does not exist').ToUpper()
     }
     while($strName -eq "") {
        cls
        $strName = Read-Host "Please enter your first and last name"
     
     }
     $tDate =get-date
     $strDate = $tDate.ToString()
     Add-Content -Path ($FullPathToSoundFiles +"\Playlist\Log.txt") -Value ($strName + " edited myConfig.txt " + $strDate ) -Force
     Set-ItemProperty -Path $strFile -Name IsReadOnly -Value $false
     Set-ItemProperty -Path ($FullPathToSoundFiles +"\Playlist\Log.txt") -Name IsReadOnly -Value $true
     
     Start-Program
     
}
function Play-Sound{
    param (
        [string] $FullPathToSoundFiles= 'c:\users\user\projects\music' #--this part is the default. Can be overwritten by the parameter passed from the calling function
    )
try
    {
        $intStart=1
        $intEnd=1
        #test to make sure that the directory passed to this routine exists
        while (-not (Test-Path $FullPathToSoundFiles)) {
            $FullPathToSoundFiles = Read-Host -Prompt "Please enter parent folder for Playlist directory"
        }
        $Path= $FullPathToSoundFiles +"\PlayList"
        if(-not (Test-Path $Path)){
            Write-Host "The  following directory does not exist:  " $Path 
            return
        }
        #try{Get-Item -Path $Path -ErrorAction Inquire}catch{Write-Host "Attempt to access unavailable directory failed"}
    Do{
        $intNoOfSndFile = Get-NumberOfSoundFiles ($Path + "\Regular\")
        if ($intNoOfSndFile -gt 0) {
            #Play ($Path + "\Regular\") -Shuffle -Loop
            Play-CurrentFile ($Path + "\Regular\") 1 1 
        }else{Write-Host 'No media in Regular folder. Waiting for schduled program  . . .'}
        Do{
            $arAllFoldersAndTimes = Refresh-Configuration
            
            $tDate = get-date
            $tDate = $tDate.ToLongTimeString()
            $intFileCount=0
            $strFolder=""
             $arAllFoldersAndTimes | foreach{
               try{
                   $strCurrentTime = $_.Substring($_.IndexOf("=")+1)
                   $strCurrentTime = [datetime]$strCurrentTime.Replace("'","")
                   $strCurrentTime = $strCurrentTime.ToLongTimeString()
           
                   $strCurrentFolder = $_.Substring($_.IndexOf("#")+1)
                   $strCurrentFolder = $strCurrentFolder.Substring(0,($strCurrentFolder.IndexOf('=')))
                   if($strCurrentTime -eq $tDate){
                        Play-CurrentFile ($Path + ('\' + $strCurrentFolder)) 0 0
                        break
                    }
                }catch{
                    Write-Host "Unexpected error occured. Check all date formats in myConfig.txt"
                    break
                }          
         }
        }while($intStart -eq 1) 
     }while($intEnd=1)
}catch [System.Management.Automation.ItemNotFoundException]{
    Log-Error "Play-Sound: Cannot find path to the directory specified"  
     }
catch [System.Management.Automation.ParameterBindingException]{
      Log-Error "Play-Sound: Error has occured. Check your dates. They should be in the following formart:
         'c:\users\user\projects\music' 'xx:xx:xx AM' 'xx:xx:xx AM' 'xx:xx:xx AM' 'xx:xx:xx AM'.
         If problem continues send email to Help Desk"    
    }
catch{
    Log-Error $_
    }
}
function Play-SpecialProgram{
    param(
        [string] $FullPathToSoundFiles='c:\users\user\projects\music' #--this part is the default. Can be overwritten by the parameter passed from the calling function
    )
    while (-not (Test-Path $FullPathToSoundFiles)) {
        $FullPathToSoundFiles = Read-Host -Prompt "Please enter parent folder for PlayList directory"
    
    }
    $temp = $FullPathToSoundFiles + "\PlayList\Special"
    try{Get-Item -Path $temp -ErrorAction Inquire}catch{Log-Error "Play-SpecialProgram: Attempt to access unavailable directory failed"}
    Play-CurrentFile $temp 0 1
}

function Play-ForDaysOfWeek{
  param(
        [string] $FullPathToSoundFiles='c:\users\user\projects\music' #--this part is the default. Can be overwritten by the parameter passed from the calling function
    )
    while (-not (Test-Path $FullPathToSoundFiles)) {
        $FullPathToSoundFiles = Read-Host -Prompt "Please enter parent folder for PlayList directory"
    
    }
     $intEnd=0
     $FullPathToSoundFiles=$FullPathToSoundFiles +'\PlayList\DayOfWeek'
     Write-Host "Waiting for next due time . . . "
     do{
        $cDate = get-date
        $strDayOfWeek = $cDate.DayOfWeek
        $cTime = Get-Date -UFormat "%R"
        $strTime = ($cTime.ToString()).Replace(":","")
        $strDirectory = ($FullPathToSoundFiles + "\" + $strDayOfWeek + "\" + $strTime)
        if(Test-Path -LiteralPath $strDirectory){
            if((Get-NumberOfSoundFiles $strDirectory) -gt 0){
                Play-CurrentFile $strDirectory  0 0
                Start-Sleep 120
            }else{
                cls
                Log-ErrorNoRestart ('ALERT:  No media file to play at ' + $strDirectory)
                Write-Host 'Waiting for next due time  . . . '
                Start-Sleep 60
            }
        }
        
    } while($intEnd -eq 0)
}

function Prepare-Folders{  
    try{
       $myFolder=""
       $myFolder = Read-Host -Prompt "Please enter parent folder"
       if (-not (Test-Path -LiteralPath ($myFolder + "\PlayList"))){
            Write-Host $myFolder
            New-Item -Path ($myFolder + "\PlayList") -ItemType "directory"
            New-Item -Path ($myFolder + "\PlayList\Regular") -ItemType "directory"
            New-Item -Path ($myFolder + "\PlayList\Special") -ItemType "directory"
            New-Item -Path ($myFolder + "\PlayList\First") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\Second") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\Third") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\Fourth") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\DayOfWeek") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\DayOfWeek\Monday") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\DayOfWeek\Tuesday") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\DayOfWeek\Wednesday") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\DayOfWeek\Thursday") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\DayOfWeek\Friday") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\DayOfWeek\Saturday") -ItemType "directory"
            New-Item  -Path ($myFolder + "\PlayList\DayOfWeek\Sunday") -ItemType "directory"}
        else {
            Log-Error ($myFolder + "\PlayList")  "folder already exists"
        }
    }catch{
        Log-Error "Error has occured. Unable to create a folder"
    }  
 }

function Play-CurrentFile{
    param(
        [string] $strDirectory,
        [int] $intShuffle,
        [int] $intLoop
    )
    $Files = Get-ChildItem -Path $strDirectory
    $FileExists = 'Yes'
    if($Files.Count -le 0){
        $FileExists='No'
        Log-Error ('ALERT:  No media file to play at ' + $strDirectory)
    }
    
    $Files | ForEach-Object{
        #do not play if a file is less than 500KB
        if( ($_.Length/1000) -le 500){
            $FileExists='No'
            Log-Error (('PLEASE NOTE: A file in ' + $strDirectory) + 'is less than 500KB. Such a small file is not supported Will now default to weekday settings')
        }
    }
    if ($FileExists -eq 'Yes'){
        $intPlayDuration=30
        $strPlayProps=""
        if(($intShuffle -eq 1) -and ($intLoop -eq 1)){
             $strPlayProps = play $strDirectory -Shuffle -Loop
        }
       if(($intShuffle -eq 1) -and ($intLoop -eq 0)){
             $strPlayProps = play $strDirectory -Shuffle 
        }
       if(($intShuffle -eq 0) -and ($intLoop -eq 1)){
             $strPlayProps = play $strDirectory -Loop
        }
       if(($intShuffle -eq 0) -and ($intLoop -eq 0)){
             $strPlayProps = play $strDirectory 
        }
    
        $intPlayDuration = $strPlayProps.'PlayDuration(in mins)'
        if($intPlayDuration -eq 'Infinite'){
            Write-Host "Current file(s) will play indefinitely"
        }
        else{
            Write-Host "Current file will play for" $intPlayDuration  "minutes"
            }
        Write-Host ('Playing program from: ' + $strDirectory  + '. Time Started: ' + (get-date).ToShortTimeString())
        if(-not ($intPlayDuration -eq 'Infinite')){       
            Start-Sleep ((60 * $intPlayDuration) + 7)
            }
    }elseif($FileExists -eq 'No'){
        #Play-ForDaysOfWeek
    }
}

function Get-NumberOfSoundFiles{
    param(
        [string] $SoundFolder= '' #--this part is the default. Can be overwritten by the parameter passed from the calling function
    )
    $intFileCount =  (Get-ChildItem $SoundFolder -File -Filter '*.MP3' | Measure-Object).Count
    $intFileCount =  $intFileCount + (Get-ChildItem $SoundFolder -File -Filter '*.MP4' | Measure-Object).Count
    return $intFileCount
}

function Log-Error() {
    param(
        [string] $strError = 'Error has occured'
    )
    $strLog = Get-ConfigurationFile
    $strLog = $strLog + "\Playlist\Errorlog.txt"
    $dtDate = get-date
    Write-Host 
    Write-Host $strError
    Write-Host
    Add-Content -Path $strLog -Value $strError
    Add-Content -Path $strLog $dtDate
}
function Log-ErrorNoRestart() {
    param(
        [string] $strError = 'Error has occured'
    )
    $strLog = Get-ConfigurationFile
    $strLog = $strLog + "\Playlist\Errorlog.txt"
    $dtDate = get-date
    Write-Host 
    Write-Host $strError
    Write-Host
    Add-Content -Path $strLog -Value $strError
    Add-Content -Path $strLog $dtDate
}
cls
$strConfigGlobal = Get-Location
$strConfigGlobal = ($strConfigGlobal.ToString() +"\Playlist\myconfig.txt")
Get-ConfigurationFile
write-host
Write-Host "KHCONF ONLINE RADIO" -ForegroundColor yellow 
Start-Program