$sb = {
    $query = "SELECT * FROM CIM_DATAFILE WHERE Extension='mp4'"
    Get-WmiObject -Query $query | Select name
}

#Measure-Command -Expression $sb
Invoke-Command $sb

#On a specific folder
$folder = {
    $query = "SELECT * FROM CIM_DATAFILE WHERE Drive = 'C:' AND Path = '\\powershell\\'"
    Get-WmiObject -Query $query | Select Name
}
Invoke-Command $folder

#Select a new file
$ab = {
    "SELECT * FROM CIM_DATAFILE WHERE Extension='txt'"
    Get-WmiObject -Query $query | Select Name
    }
   Invoke-Command $ab

$ac = {
    $query = "SELECT * FROM CIM_DATAFILE WHERE Writeable= '$false'"
    Get-WmiObject -Query $query | Select Name
}
Invoke-Command $ac | format-table -wrap