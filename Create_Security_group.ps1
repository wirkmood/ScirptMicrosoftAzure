##########################################
#             Sécurity group             #
##########################################


# Cloud variables
$RM = Get-AzureRmResourceGroup 
$loc = Get-AzureRmLocation | where {$_.Location -imatch "westeurope"}
$StorageAccount = "yourStorageAccountName"

# Create an inbound network security group rule for port 80
$nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig -Name SecurityGroupHTTP  -Protocol Tcp `
    -Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 80 -Access Allow

# Create an inbound network security group rule for port 22 (SSH)
$nsgRuleSSH = New-AzureRmNetworkSecurityRuleConfig -Name SecurityGroupSSH -Protocol Tcp `
    -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
    -DestinationPortRange 22 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $RM.ResourceGroupName -Location $loc.Location `
    -Name SecurityGroup-001 -SecurityRules $nsgRuleSSH,$nsgRuleWeb
