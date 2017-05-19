# get automation variables
$shutdownResourceGroup = Get-AutomationVariable -Name 'shutdownResourceGroup'

$Conn = Get-AutomationConnection -Name AzureRunAsConnection
Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
-ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

Get-AzureRmVm -ResourceGroupName $shutdownResourceGroup | Stop-AzureRmVm