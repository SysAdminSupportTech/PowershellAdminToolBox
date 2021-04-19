<#
.Description
Send-UCMailMessage function serves as a helping function to send attachement as an output from other cmdlet commands.
.Example
1. Sending a mail to a receipient without  an attachment
Send-UCSendMail -From "jbethel@bethel.jw.org" -To "jbethel@bethel.jw.org" -Subject "As Attached" -Body "As Requested"

2. Sending a mail with an attachment
Send-UCSendMail -From "jbethel@bethel.jw.org" -To "jbethel@bethel.jw.org" -Subject "As Attached" -Body "As Requested" -AttachFile.

.PARAMETER Attachfile
Switched parameter activate the attached file feature in the script. 

#>
function Send-UCMailMessage{
    [cmdletBinding ()]
    param(
        $PSEmailServer = 'nlmail044.bethel.jw.org',
        $Attachment,
        [String]$Body,
        [Parameter(ValueFromPipeline = $true)]
        [switch]$AttachFile,
        [Parameter(Mandatory= $true,
        Position = 0)]$From,
        [PARAMETER(Mandatory = $true,
        Position = 1)]
        [String[]]$To,
        [PARAMETER(Mandatory = $true)]$Subject

    )
    Write-Host "This program is developed as a function used in sending mails to anybody" -ForegroundColor DarkGreen

    <#-------------------- Splatting----------------------------------------------#>
    $obj_param = @{
        From = $from
        To = $To
        Subject = $Subject
        Body = $Body
        SmtpServer = $PSEmailServer
        DeliveryNotificationOption = 'OnSuccess, OnFailure'
    }

    <#--------------------Decision if a user want to attached a file----------------------------------------------#>
    $UserCredential = Read-Host 'Please Provide Your First Account User Credential. eg domain\jbethel' #Getting User Credential

    if ($AttachFile){
        $FilePath = Read-Host "Provide A Path to the Attached File"
        Send-MailMessage @obj_param -Attachments $FilePath -Credential $UserCredential     
    } Else {
        Write-Warning "Your Mail Will be sent without an Attachement."
        Send-MailMessage @obj_param -Credential $UserCredential
    }
}


<#----------------------------------------------------------------------------------------------------------------#>
                                    #Sending output to a printer
<#----------------------------------------------------------------------------------------------------------------#>