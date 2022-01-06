(import-csv -Path "C:\Users\ealbert\Documents\client Administration\Documents\Retention_Policy\A.csv").Path | 
ForEach-Object {
    if(($_) -eq [System.IO.DirectoryInfo]){
    "directory"
        $_ | Out-File -FilePath "C:\Users\ealbert\Documents\client Administration\Documents\Retention_Policy\dir.txt"
    } Else {
          move-Item $_ -Destination "H:\CD\User and Client Support\Correspondence (ACT+3)\To Be Deleted\2021\04 December 2021" -Force -Verbose
          
    }
    
}