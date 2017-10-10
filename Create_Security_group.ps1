##########################################
#             Sécurity group             #
##########################################

try {
    # Login on Microsoft Azure
    $Subscription = Get-AzureRmSubscription -ErrorAction:0
}
catch {
    Write-Host -f Red "you're not connected on Microsoft Azure"
}


if ($Subscription -eq $null){
    Login-AzureRmAccount
    $Subscription = Get-AzureRmSubscription
}
else {
    Write-Host -ForegroundColor Green "You're already connected on Microsoft Azure"
}

# Cloud variables
$RM = Get-AzureRmResourceGroup 
$loc = Get-AzureRmLocation | where {$_.Location -imatch "westeurope"}
$StorageAccount = "yourStorageAccountName"

###############################
# Create a new Security group
###############################

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
