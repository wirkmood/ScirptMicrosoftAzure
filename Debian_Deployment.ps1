################################################
#    Debian VM Deployment on Microsoft Azure   #
################################################


################################################
# Prequis :                                    #
# - Network                                    #
# - Subnet                                     #
# - Storage Account                            #
# - Security group                             #
################################################


<#
- Image: Debian 8.6
- VM Size: Standard_DS13
#>


################################################
# Login On Microsft Azure                      #
################################################

try {
    # Login on Microsoft Azure
    $Subscription = Get-AzureRmSubscription -ErrorAction:0
}

catch {

}


if ($Subscription -eq $null){
    Login-AzureRmAccount
    $Subscription = Get-AzureRmSubscription
}
else {
    Write-Host -ForegroundColor Green "You're already connected on Microsoft Azure"
}

# Cloud variables (RM/ Location / storage account)
$RM = Get-AzureRmResourceGroup 
$loc = Get-AzureRmLocation | where {$_.Location -imatch "westeurope"}
$StorageAccount = "yourStorageAccountName"

################################################
#      Get Network and Security Group          #
################################################

$vnet = Get-AzureRmVirtualNetwork | ? {$_.Name -imatch "Net-lab-001"}
$nsg = Get-AzureRmNetworkSecurityGroup | ? {$_.Name -imatch "SecurityGroup-001"}

################################################
#      Select your image (Debian-9)            #
################################################

# Select the Publisher credativ (debian)
$publisher = Get-AzureRmVMImagePublisher  -Location $loc.Location | ? {$_.PublisherName -imatch "credativ"}

# Select the offer Debian
$offer = Get-AzureRmVMImageOffer -Location $loc.Location -PublisherName $publisher.PublisherName

#Select the SKUS (debian's version)
$skus = Get-AzureRmVMImageSku -Location $loc.Location -PublisherName $publisher.PublisherName -Offer $offer.Offer | ? {$_.Skus -eq "9-DAILY"}

#########################################
#      Select credential and VMSize     #
#########################################

# Define a credential object
$cred = Get-Credential -Message "Login vm" 

# VMsize Standard DS1
$VMSize = Get-AzureRmVMSize $loc.Location | ? {$_.Name -eq "Standard_DS1"}

##########################################
#         Configure & CREATE VM          #
##########################################

for ($i=1 ; $i -le 1; $i++){
    $vnicname = "vnic-docker-$i"
    $pipname  = "PublicIp-00$i"
    $vmname   = "docker-$i"
	
    try {
        $check_pip = Get-AzureRmPublicIpAddress -Name $pipname -ResourceGroupName $RM.ResourceGroupName -ErrorAction:0
        $check_vnic = Get-AzureRmNetworkInterface -Name $vnicname -ResourceGroupName $RM.ResourceGroupName -ErrorAction:0
        $check_vm = Get-AzureRmVM -Name $vmname -ResourceGroupName $RM.ResourceGroupName  -ErrorAction:0
    }

    catch {
        Write-Host -ForegroundColor Green "Public IP $pipname doesn't exist"
        Write-Host -ForegroundColor Green "Vnic $vnicname doesn't exist"
    }
    
# Condition to deploy public IP
    if($check_pip -eq $null){
     # Create a new public IP 
        $public = New-AzureRmPublicIpAddress -Location $loc.Location -ResourceGroupName $RM.ResourceGroupName ` -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name $pipname
    }

    elseif ($check_pip.IpConfiguration.Id -eq $null){
        $public = Get-AzureRmPublicIpAddress -Name $pipname -ResourceGroupName $RM.ResourceGroupName
    }

    else {
        $message = Write-Host -f Red "$pipname is already used by a vnic thus the script cannot proceed" -ErrorAction Ignore
        return $message   
    }

# Condition to deploy a vnic card
    if($check_vnic -eq $null){
     # Creat a new VNIC
        $vnic = New-AzureRmNetworkInterface -DnsServer 8.8.8.8 -Name $vnicname -ResourceGroupName $RM.ResourceGroupName -Location $loc.Location `
        -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $public.Id -NetworkSecurityGroupId $nsg.Id 
    }
    elseif($check_vnic.VirtualMachine -eq $null){
        $vnic = New-AzureRmNetworkInterface -DnsServer 8.8.8.8 -Name $vnicname -ResourceGroupName $RM.ResourceGroupName -Location $loc.Location `
        -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $public.Id -NetworkSecurityGroupId $nsg.Id 
    }
    else {
        $message = Write-Host -f Red "$vnicname is already used then the script can't proceed" -ErrorAction Stop
        return $message
    }

# Condition to deploy a VM 
    if ($check_vm -eq $null){
    # Create a virtual machine configuration
        $vmConfig = New-AzureRmVMConfig -VMName $vmname -VMSize $VMSize.Name | `
        Set-AzureRmVMOperatingSystem -Linux -ComputerName $vmname -Credential $cred | `
        Set-AzureRmVMSourceImage -PublisherName $publisher.PublisherName -Offer $offer.Offer `
        -Skus $skus.Skus -Version latest | Add-AzureRmVMNetworkInterface -Id $vnic.Id

    # Deployment with vmconfig's attribute
        $VMcreated = New-AzureRmVM -ResourceGroupName $RM.ResourceGroupName -Location $loc.Location -VM $vmConfig
    }

    else{
        $message = Write-Host -f Red "$vnicname is already used then the script can't proceed" -ErrorAction Stop
        return $message 
    }
}