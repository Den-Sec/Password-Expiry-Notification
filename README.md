# Password Expiry Notification Script

This PowerShell script automates the process of notifying Active Directory (AD) users about their upcoming password expiration. It retrieves all users from the domain, calculates their password expiration date, and sends an email notification if their password is due to expire within a configurable number of days.

The script is designed to run on a **Domain Controller** and requires that users in Active Directory have valid email addresses set in their accounts.

---

## Features

- Automatically calculates password expiration dates for all AD users.
- Sends email notifications to users whose passwords are about to expire.
- Customizable expiration warning period (e.g., 10 days before expiration).
- Supports day/month/year date format in email notifications.
- Creates detailed logs for execution and error tracking.
- Can be scheduled to run daily using Task Scheduler.

---

## Requirements

- The script must run on a **Domain Controller** with the **Active Directory PowerShell module** installed.
- Active Directory users must have a valid email address set in their `EmailAddress` property.
- The SMTP server configuration must be valid (tested with `ssl0.ovh.net` in this script).
- Proper permissions to read AD user properties and send emails.

---

## How to Use

### 1. **Modify the Script**

#### **Change the SMTP Configuration**
Update the following lines in the script to match your SMTP server credentials:
```powershell
$smtpServer = "<Your SMTP Server>"
$smtpPort = <Your SMTP Port>
$smtpFrom = "<Your Email Address>"
$smtpCredential = New-Object System.Management.Automation.PSCredential (
    "<Your Email Address>",
    (ConvertTo-SecureString "<Your Password>" -AsPlainText -Force)
)
```
Replace `<Your SMTP Server>`, `<Your SMTP Port>`, `<Your Email Address>`, and `<Your Password>` with your actual SMTP server details and credentials.

#### **Customize the Days Before Expiry Notification**
To change how many days before the password expiration users are notified, update this line:
```powershell
$notificationDate = $passwordExpirationDate.AddDays(-10)
```
For example, to notify users **7 days** before expiry, change it to:
```powershell
$notificationDate = $passwordExpirationDate.AddDays(-7)
```

#### **Update Date Format in Emails**
The script uses the **day/month/year** format in emails. This can be customized by modifying this line:
```powershell
$formattedExpirationDate = $passwordExpirationDate.ToString("dd/MM/yyyy")
```
For other formats, refer to .NET date formatting documentation: <https://learn.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings>

---

### 2. **Run the Script as a Scheduled Task**

To automate the script and run it daily, follow these steps:

#### **Create a Scheduled Task**
1. Open **Task Scheduler** (`taskschd.msc`).
2. Click **Create Task**.
3. On the **General** tab:
   - Name: `Password Expiry Notification`.
   - Select **Run whether user is logged on or not**.
   - Check **Run with highest privileges**.
4. On the **Triggers** tab:
   - Create a new trigger to run **Daily** at **8:00 AM**.
5. On the **Actions** tab:
   - Action: **Start a Program**.
   - Program/script: `powershell.exe`.
   - Add arguments:
     ```plaintext
     -File "C:\Scripts\PasswordExpiryNotification.ps1"
     ```
6. On the **Settings** tab:
   - Check **Allow task to be run on demand**.

#### **Verify Execution**
- Run the task manually from Task Scheduler to ensure it works.
- Check the log file at `C:\Scripts\Logs\PasswordNotificationLog.txt` for details.

---

## Logs

The script logs its execution to a file named `PasswordNotificationLog.txt` located in `C:\Scripts\Logs`. This includes details of:
- Script start and completion times.
- Emails sent successfully.
- Errors encountered while sending emails.

---

## Troubleshooting

### **Common Issues**
1. **Emails Not Being Sent**:
   - Verify the SMTP server and credentials.
   - Check if the SMTP port (`587` or `465`) is open in the firewall.
2. **Users Not Receiving Notifications**:
   - Ensure the `EmailAddress` property is set for all AD users.
   - Verify the script runs with sufficient permissions.
3. **Script Execution Policy**:
   - If the script doesn't run, ensure the PowerShell execution policy allows scripts. Run:
     ```powershell
     Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
     ```

### **Debugging Tips**
- Check the log file for detailed error messages.
- Use the following command to test connectivity to the SMTP server:
  ```powershell
  Test-NetConnection -ComputerName ssl0.ovh.net -Port 587
  ```

---

## Acknowledgements

This script was designed to help IT Administrators proactively manage password expirations on Active Directory and ensure seamless user access to systems. Contributions and suggestions are welcome!
