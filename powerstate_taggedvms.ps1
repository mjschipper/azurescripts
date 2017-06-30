#Set variables
    # $shutdown = $true (this will use the shutdown commands based on the tags set in the varables of Azure)
    # $shutdown = $false  (this will use the startup commands based on the tags set in the varables of Azure) - The startup commands only starts vms on weekdays and non public holidays.
    $Shutdown = $false
 
    # URL for machine readable Australian public holidays: https://data.gov.au/dataset/australian-holidays-machine-readable-dataset/resource/a24ecaf2-044a-4e66-989c-eacc81ded62f
    $url = "http://data.gov.au/dataset/b1bc6077-dadd-4f61-9f8c-002ab2cdff10/resource/a24ecaf2-044a-4e66-989c-eacc81ded62f/download/australianpublicholidays-201617.csv"

    # get automation variables
    $tagName = Get-AutomationVariable -Name 'startupResourceTagName'
    $tagValue = Get-AutomationVariable -Name 'startupResourceTagValue'

    # Uses the credentials set when setting up your action account.
    $Conn = Get-AutomationConnection -Name AzureRunAsConnection
    Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
    -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint

    $day = Get-Date -UFormat "%A"
    $date = get-date -uformat "%Y%m%d"
    $pubhol = ForEach($line in (Invoke-RestMethod $url | ConvertFrom-Csv)){if($line."Applicable To" -like "*SA*"){$line.date}}

    #Shutdown machines
    $taggedResources = Find-AzureRmResource -TagName $tagName -TagValue $tagValue 

    $targetVms = $taggedResources | Where-Object{$_.ResourceType -eq "Microsoft.Compute/virtualMachines"} | select resourcegroupname, name | Get-AzureRmVM -status

    ForEach ($vm in $targetVms)
    {
        $currentpowerstatus = $vm |select -ExpandProperty Statuses | Where-Object{ $_.Code -match "PowerState" } | select Code, DisplayStatus
 
        if($Shutdown -and $currentpowerstatus.Code -eq "PowerState/running"){
		    Write-Output "Stopping $($vm.Name)";		
		    Stop-AzureRmVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force;
	}
	elseif($Shutdown -eq $false -and $currentpowerstatus.Code -ne "PowerState/running"){
        if($day -NotLike "S*day" -and $pubhol -notcontains $date){
		    Write-Output "Starting $($vm.Name)";		
		    Start-AzureRmVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName;
        }  
	}
        else {
            Write-Output "VM $($vm.Name) is already in desired state : $($currentpowerstatus.DisplayStatus)";
        }
    }
