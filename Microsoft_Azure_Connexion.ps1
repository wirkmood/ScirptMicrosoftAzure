#########################################
#  Script to login on Microsoft Azure   #
#########################################

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
$StorageAccount = "YOURSTORAGEACCOUNT"


