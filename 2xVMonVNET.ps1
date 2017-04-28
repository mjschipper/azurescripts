$subName = 'Visual Studio Enterprise – MPN'
 
Login-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionName $subName

# Create a new Azure Resource Manager Resource Group
New-AzureRmResourceGroup `
    -Name "EUS-ARM-DEV-ENV" `
    -Location "East US" ;
	
New-AzureRmVirtualNetwork `
    -ResourceGroupName "EUS-ARM-DEV-ENV" `
    -Location "East US" `
    -Name "EUS-ARM-DEV-ENV-VN" `
    -AddressPrefix "10.2.0.0/24" `
    -Subnet (New-AzureRmVirtualNetworkSubnetConfig `
                -Name "GatewaySubnet" `
                -AddressPrefix "10.2.0.248/29"),
            (New-AzureRmVirtualNetworkSubnetConfig `
                -Name "Subnet-DEV-ENV" `
                -AddressPrefix "10.2.0.0/25") ;
				
# Request a new Azure Resource Manager Virtual Network
#  Dynamic Public IP Address for AZUMGTSVR01
New-AzureRmPublicIpAddress `
    -ResourceGroupName "EUS-ARM-DEV-ENV" `
    -Location "East US" `
    -Name "EUS-ARM-DEV-ENV-VN-PIP-AZUMGTSVR01" `
    -AllocationMethod "Dynamic" ;

# Create an Azure Resource Manager
#  Virtual Machine configuration
$newVMConfigParams = @{
    "VMName" = "AZUMGTSVR01" ;
    "VMSize" = "Standard_A0" ;
} ;
$newAzureRmVMConfig = `
    New-AzureRmVMConfig `
        @newVMConfigParams ;
 
# Configure the Azure Resource Manager
#  Virtual Machine operating system
$newAzureRmVMOperatingSystemParams = @{
    "VM" = $newAzureRmVMConfig ;
    "Windows" = $true ;
    "ComputerName" = "azumgtsvr01" ;
    "Credential" = ( `
        Get-Credential `
            -Message "Please input new local administrator username and password.") ;
    "ProvisionVMAgent" = $true ;
    "EnableAutoUpdate" = $true ;
} ;
$AzureVirtualMachine = `
    Set-AzureRmVMOperatingSystem `
            @newAzureRmVMOperatingSystemParams ;
 
# Configure the Azure Resource Manager
#  Virtual Machine source image
$newAzureRmVMSourceImageParams = @{
    "PublisherName" = "MicrosoftWindowsServer" ;
    "Version" = "latest" ;
    "Skus" = "2016-Datacenter" ;
    "VM" = $AzureVirtualMachine ;
    "Offer" = "WindowsServer" ;
} ;
$AzureVirtualMachine = `
    Set-AzureRmVMSourceImage `
        @newAzureRmVMSourceImageParams ;
 
# Create an Azure Resource Manager
#  Virtual Machine network interface
$newAzureRmVMNetworkInterfaceParams = @{
    "Name" = "EUS-ARM-DEV-ENV-VMNI" ;
    "ResourceGroupName" = "EUS-ARM-DEV-ENV" ;
    "Location" = "East US" ;
    "SubnetId" = (
                    (
                        Get-AzureRmVirtualNetwork `
                            -ResourceGroupName "EUS-ARM-DEV-ENV" `
                    ).Subnets | `
                        Where-Object { $_.Name -eq "Subnet-DEV-ENV" }
                 ).Id ;
    "PublicIpAddressId" = (
                            Get-AzureRmPublicIpAddress `
                                -Name "EUS-ARM-DEV-ENV-VN-PIP-AZUMGTSVR01" `
                                -ResourceGroupName "EUS-ARM-DEV-ENV"
                          ).Id ;
} ;
$newAzureRmVMNetworkInterface = `
    New-AzureRmNetworkInterface `
        @newAzureRmVMNetworkInterfaceParams ;
 

# Add Azure Resource Manager
#  Virtual Machine network interface
#  to Azure Virtual Machine
$AzureVirtualMachine = `
    Add-AzureRmVMNetworkInterface `
        -VM $AzureVirtualMachine `
        -Id $newAzureRmVMNetworkInterface.Id ;  
 
# Create an Azure Resource Manager
#  storage account for Virtual Machine
#  VHD creation
$newAzureRmStorageAccountParams = @{
    "ResourceGroupName" = "EUS-ARM-DEV-ENV" ;
    "Location" = "East US" ;
    "Name" = "eus9storage9account0001" ;
    "Kind" = "Storage" ;
    "Type" = "Standard_LRS" ;
} ;
$newAzureRmStorageAccount = `
    New-AzureRmStorageAccount `
        @newAzureRmStorageAccountParams ;
 
# Construct Azure Virtual Machine
#  operating system VHD disk Uri
$newAzureRmOperatingSystemDiskUri = `
    $newAzureRmStorageAccount.PrimaryEndpoints.Blob.ToString() + `
        "vhds/" + `
        $newAzureRmVMConfig.Name + `
        "_OperatingSystem" + `
        ".vhd" ;
 
# Configure the Azure Resource Manager
#  Virtual Machine operating system disk
$newOperatingSystemDiskParams = @{
    "Name" = "OperatingSystem" ;
    "CreateOption" = "fromImage" ;
    "VM" = $AzureVirtualMachine ;
    "VhdUri" = $newAzureRmOperatingSystemDiskUri ;
} ;
$AzureVirtualMachine = `
    Set-AzureRmVMOSDisk `
        @newOperatingSystemDiskParams ;
 
# Create an Azure Resource Manager
#  Virtual Machine now
$newAzureRmVirtualMachineParams = @{
    "ResourceGroupName" = "EUS-ARM-DEV-ENV" ;
    "Location" = "East US" ;
    "VM" = $AzureVirtualMachine ;
} ;
New-AzureRmVM `
    @newAzureRmVirtualMachineParams ;
	
# Request a new Azure Resource Manager Virtual Network
#  Dynamic Public IP Address
New-AzureRmPublicIpAddress `
    -ResourceGroupName "EUS-ARM-DEV-ENV" `
    -Location "East US" `
    -Name "EUS-ARM-DEV-ENV-VN-PIP-AZUDCSVR01" `
    -AllocationMethod "Dynamic" 
} ;  
 

# Create an Azure Resource Manager
#  Virtual Machine configuration
$newVMConfigParams = @{
    "VMName" = "AZUDCSVR01" ;
    "VMSize" = "Standard_A0" ;
} ;
$newAzureRmVMConfig = `
    New-AzureRmVMConfig `
        @newVMConfigParams ;
 

# Configure the Azure Resource Manager
#  Virtual Machine operating system
$newAzureRmVMOperatingSystemParams = @{
    "VM" = $newAzureRmVMConfig ;
    "Windows" = $true ;
    "ComputerName" = "AZUDCSVR01" ;
    "Credential" = ( `
        Get-Credential `
            -Message "Please input new local administrator username and password.") ;
    "ProvisionVMAgent" = $true ;
    "EnableAutoUpdate" = $true ;
} ;
$AzureVirtualMachine = `
    Set-AzureRmVMOperatingSystem `
            @newAzureRmVMOperatingSystemParams ;  
 
# Configure the Azure Resource Manager
#  Virtual Machine source image
$newAzureRmVMSourceImageParams = @{
    "PublisherName" = "MicrosoftWindowsServer" ;
    "Version" = "latest" ;
    "Skus" = "2016-Nano-Server" ;
    "VM" = $AzureVirtualMachine ;
    "Offer" = "WindowsServer" ;
} ;
$AzureVirtualMachine = `
    Set-AzureRmVMSourceImage `
        @newAzureRmVMSourceImageParams ;
 

# Create an Azure Resource Manager
#  Virtual Machine network interface
$newAzureRmVMNetworkInterfaceParams = @{
    "Name" = "EUS-ARM-DEV-ENV-VMNI-AZUDCSVR01" ;
    "ResourceGroupName" = "EUS-ARM-DEV-ENV" ;
    "Location" = "East US" ;
    "SubnetId" = (
                    (
                        Get-AzureRmVirtualNetwork `
                            -ResourceGroupName "EUS-ARM-DEV-ENV" `
                    ).Subnets | `
                        Where-Object { $_.Name -eq "Subnet-DEV-ENV" }
                 ).Id ;
    "PublicIpAddressId" = (
                            Get-AzureRmPublicIpAddress `
                                -Name "EUS-ARM-DEV-ENV-VN-PIP-AZUDCSVR01" `
                                -ResourceGroupName "EUS-ARM-DEV-ENV"
                          ).Id ;
} ;
$newAzureRmVMNetworkInterface = `
    New-AzureRmNetworkInterface `
        @newAzureRmVMNetworkInterfaceParams ;
 

# Add Azure Resource Manager
#  Virtual Machine network interface
#  to Azure Virtual Machine
$AzureVirtualMachine = `
    Add-AzureRmVMNetworkInterface `
        -VM $AzureVirtualMachine `
        -Id $newAzureRmVMNetworkInterface.Id ;
 

# Get the Existing Azure Resource Manager
#  storage account for Virtual Machine
#  VHD creation
$ExistingAzureRmStorageAccount = `
    Get-AzureRmStorageAccount `
        -Name "eus9storage9account0001" `
        -ResourceGroupName "EUS-ARM-DEV-ENV" ;
 

# Construct Azure Virtual Machine
#  operating system VHD disk Uri
$newAzureRmOperatingSystemDiskUri = `
    $ExistingAzureRmStorageAccount.PrimaryEndpoints.Blob.ToString() + `
        "vhds/" + `
        $newAzureRmVMConfig.Name + `
        "_OperatingSystem" + `
        ".vhd" ;
 

# Configure the Azure Resource Manager
#  Virtual Machine operating system disk
$newOperatingSystemDiskParams = @{
    "Name" = "OperatingSystem" ;
    "CreateOption" = "fromImage" ;
    "VM" = $AzureVirtualMachine ;
    "VhdUri" = $newAzureRmOperatingSystemDiskUri ;
} ;
$AzureVirtualMachine = `
    Set-AzureRmVMOSDisk `
        @newOperatingSystemDiskParams ;
 

# Create an Azure Resource Manager
#  Virtual Machine now
$newAzureRmVirtualMachineParams = @{
    "ResourceGroupName" = "EUS-ARM-DEV-ENV" ;
    "Location" = "East US" ;
    "VM" = $AzureVirtualMachine ;
} ;
New-AzureRmVM `
    @newAzureRmVirtualMachineParams ;
