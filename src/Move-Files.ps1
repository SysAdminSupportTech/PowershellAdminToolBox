(import-csv -Path "C:\Powershell\Scripts\Files\book.csv").Path | 
ForEach-Object {
    if(($_) -eq [System.IO.DirectoryInfo]){
    "directory"
        $_ | Out-File -FilePath "C:\Users\ealbert\Documents\client Administration\Documents\Retention_Policy\dir.txt"
    } Else {
          move-Item $_ -Destination "H:\CD\Office Machine\Tasks (ACT+3)\To Be Deleted\2021\04 December 2021" -Force -Verbose
          
    }
    
}