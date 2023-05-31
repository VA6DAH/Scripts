# Author: Dakota Hourie
# Date Created: 2023-05-30

# Description: This script will check the current users password expiration date and show a toast notification if the password will expire in less than 85 days.
# The notification will have two buttons, one to change the password and one to dismiss the notification. The notification will persist until the user dismisses it.

# This script is intended to be run as a scheduled task on a Windows 10+ device. The scheduled task should be configured to run as the current user and to run at logon.

# Start of Script

# Prerequisites
Install-Module -Name BurntToast -RequiredVersion 0.8.5

# Parameters
$StartRemindingDays = 7

# Use 'Net User' to retrieve the expiry date of the current users password. Convert this into three variables, Day, Month and Year.
$PasswordExpirationDate = (net user $env:USERNAME /domain | Select-String "Password expires" | ForEach-Object { $_.ToString().Substring(29) }).TrimEnd(".").Substring(0,10)

# Convert $PasswordeExpirationDate into variables 'day' 'month' and 'year'
$Day = $PasswordExpirationDate.Substring(8,2)
$Month = $PasswordExpirationDate.Substring(5,2)
$Year = $PasswordExpirationDate.Substring(0,4)

# Create a new timespan object with the password expiration date as the end date. Subtract this from the current date to get the number of days left until the password expires. The result is stored in the variable $DaysLeft
New-TimeSpan -End (Get-Date -Year $Year -Month $Month -Day $Day) | ForEach-Object { $DaysLeft = $_.Days }

# Create a $Notice variable with the number of days left until the password expires. Ensure it is plural if there is more than one day left.
if ($DaysLeft -gt 1) {
    $Notice = "Your password will expire in $DaysLeft days."
} else {
    $Notice = "Your password will expire in $DaysLeft day."
}

# Show Toast Notification only if the password will expire in less than $StartRemindingDays days. Make this notificaiton persistant until the user dismisses it. Exit 1 else exit 0.
if ($DaysLeft -le $StartRemindingDays) {
    $AADReset = New-BTButton -Content "Change Password" -Arguments "https://account.activedirectory.windowsazure.com/ChangePassword.aspx" -ActivationType Protocol
    $DismissButton = New-BTButton -Content "Dismiss" -Arguments "Dismiss" -ActivationType Protocol
    New-BurntToastNotification -Text $Notice -Button $AADReset,$DismissButton -AppLogo False -UniqueIdentifier "PasswordExpirationReminder"
    exit 1
} else {
    exit 0
}

# End of Script