##########################################
#                Network                 #
##########################################

# Cloud variables (RM/ Location / storage account)
$RM = Get-AzureRmResourceGroup 
$loc = Get-AzureRmLocation | where {$_.Location -imatch "westeurope"}
$StorageAccount = "yourStorageAccountName"


# Create a subnet configuration
$subnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name "Subnet-002" -AddressPrefix 172.16.1.0/24 

# Create a virtual network
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $RM.ResourceGroupName -Name "Net-lab-002" -AddressPrefix 172.16.0.0/16 -Location $loc.Location -Subnet $subnetConfig 

# Create a public IP address and specify a DNS name
$pip = New-AzureRmPublicIpAddress -ResourceGroupName $RM.ResourceGroupName -Location $loc.Location ` -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "PublicIp-$(Get-Random)"

$vnicname = "vnic-00"

for ($i=1 ; $i -le 2; $i++){
# Create a virtual network card and associate with public IP address and NSG
$nic = New-AzureRmNetworkInterface -DnsServer 8.8.8.8 -Name $vnicname-$i -ResourceGroupName $RM.ResourceGroupName -Location $loc.Location `
    -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id 
}