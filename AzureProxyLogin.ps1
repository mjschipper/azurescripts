# Windows credentials for proxy authentication.
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

#Azure Login.
Login-AzureRmAccount
Get-AzureRmSubscription
