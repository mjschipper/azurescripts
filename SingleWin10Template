# Request a new Azure Resource Manager Virtual Network
#  Dynamic Public IP Address for AZULABDT01
New-AzureRmPublicIpAddress `
    -ResourceGroupName "EUS-ARM-PRD-ENV" `
    -Location "East US" `
    -Name "EUS-ARM-PRD-ENV-VN-PIP-AZULABDT01" `
    -AllocationMethod "Dynamic" ;

# Create an Azure Resource Manager
#  Virtual Machine configuration
$newVMConfigParams = @{
    "VMName" = "AZULABDT01" ;
    "VMSize" = "Standard_DS2_v2_Promo" ;
} ;
$newAzureRmVMConfig = `
    New-AzureRmVMConfig `
        @newVMConfigParams ;
 
# Configure the Azure Resource Manager
#  Virtual Machine operating system
$newAzureRmVMOperatingSystemParams = @{
    "VM" = $newAzureRmVMConfig ;
    "Windows" = $true ;
    "ComputerName" = "AZULABDT01" ;
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
    "PublisherName" = "MicrosoftVisualStudio" ;
    "Version" = "latest" ;
    "Skus" = "Windows-10-N-x64" ;
    "VM" = $AzureVirtualMachine ;
    "Offer" = "Windows" ;
} ;
$AzureVirtualMachine = `
    Set-AzureRmVMSourceImage `
        @newAzureRmVMSourceImageParams ;
 
# Create an Azure Resource Manager
#  Virtual Machine network interface
$newAzureRmVMNetworkInterfaceParams = @{
    "Name" = "EUS-ARM-PRD-ENV-VMNI-AZULABDT01" ;
    "ResourceGroupName" = "EUS-ARM-PRD-ENV" ;
    "Location" = "East US" ;
    "SubnetId" = (
                    (
                        Get-AzureRmVirtualNetwork `
                            -ResourceGroupName "EUS-ARM-PRD-ENV" `
                    ).Subnets | `
                        Where-Object { $_.Name -eq "Subnet-PRD-ENV-WIN" }
                 ).Id ;
    "PublicIpAddressId" = (
                            Get-AzureRmPublicIpAddress `
                                -Name "EUS-ARM-PRD-ENV-VN-PIP-AZULABDT01" `
                                -ResourceGroupName "EUS-ARM-PRD-ENV"
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
        -Name "eus0storage0account01" `
        -ResourceGroupName "EUS-ARM-PRD-ENV" ;
 

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
    "ResourceGroupName" = "EUS-ARM-PRD-ENV" ;
    "Location" = "East US" ;
    "VM" = $AzureVirtualMachine ;
} ;
New-AzureRmVM `
    @newAzureRmVirtualMachineParams ;
