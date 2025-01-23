Import-Module ActiveDirectory

# SMTP Configuration
$smtpServer = "<Your SMTP Server>"
$smtpPort = <Your SMTP Port>
$smtpFrom = "<Your Email Address>"
$smtpCredential = New-Object System.Management.Automation.PSCredential (
    "<Your Email Address>",
    (ConvertTo-SecureString "<Your Password>" -AsPlainText -Force)
)

# Ensure the log directory exists
$logDirectory = "C:\Scripts\Logs"
if (-not (Test-Path -Path $logDirectory)) {
    New-Item -ItemType Directory -Path $logDirectory | Out-Null
}

# Log File Configuration
$logFile = "$logDirectory\PasswordNotificationLog.txt"

# Function to send email
function Send-Email {
    param (
        [string]$to,
        [string]$subject,
        [string]$body
    )

    $message = New-Object System.Net.Mail.MailMessage
    $message.From = New-Object System.Net.Mail.MailAddress($smtpFrom, "System Notification Manager")
    $message.To.Add($to)
    $message.Subject = $subject
    $message.Body = $body
    $message.IsBodyHtml = $false

    $smtp = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtp.EnableSsl = $true
    $smtp.Credentials = $smtpCredential

    try {
        $smtp.Send($message)
        Write-Host "Email sent to $($to)"
        Add-Content -Path $logFile -Value "[$(Get-Date)] Email sent to $($to)"
    } catch {
        # Extract the exception message to a variable
        $errorMessage = $_.Exception.Message
        Write-Host "Failed to send email to $($to): $errorMessage"
        Add-Content -Path $logFile -Value "[$(Get-Date)] Failed to send email to $($to): $errorMessage"
    }
}

# Log script execution start
Add-Content -Path $logFile -Value "[$(Get-Date)] Script execution started"

# Get current date
$currentDate = Get-Date

# Get all users in the domain
$users = Get-ADUser -Filter * -Property DisplayName, EmailAddress, PasswordLastSet, PasswordNeverExpires, AccountExpirationDate

foreach ($user in $users) {
    # Check if the user has a password expiration date
    if ($user.PasswordLastSet -ne $null -and $user.PasswordNeverExpires -eq $false) {
        $passwordExpirationDate = $user.PasswordLastSet.AddDays((Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge.Days)
        $formattedExpirationDate = $passwordExpirationDate.ToString("dd/MM/yyyy") # Format date as day/month/year

        # Check if the password will expire in 10 days
        $notificationDate = $passwordExpirationDate.AddDays(-10)
        if ($notificationDate -le $currentDate -and $passwordExpirationDate -gt $currentDate) {
            # Prepare email details
            $emailAddress = $user.EmailAddress
            if ($emailAddress) {
                $subject = "La tua password scadrà a breve"
                $body = @"
Hello $($user.DisplayName),

Your password will expire on $formattedExpirationDate. Please change it before this date to avoid access issues.

To change your password, press the key combination Ctrl + Alt + Del, then select "Change password" and follow the instructions.

If you need assistance, contact the IT support team.

Thank you,
IT Department
"@
                # Send the email
                Send-Email -to $emailAddress -subject $subject -body $body
            } else {
                Write-Host "User $($user.DisplayName) does not have an email address."
                Add-Content -Path $logFile -Value "[$(Get-Date)] User $($user.DisplayName) does not have an email address."
            }
        }
    }
}

# Log script execution end
Add-Content -Path $logFile -Value "[$(Get-Date)] Script execution completed"
