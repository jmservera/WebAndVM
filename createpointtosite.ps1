$subscriptionId="f19b7695-9685-461e-9700-2d9674197593"
$rootcertname="jmserverarootcert.cer"

$Text = Get-Content -Path "publicroot.cer"
$CertificateText = for ($i=1; $i -lt $Text.Length -1 ; $i++){$Text[$i]}
$CertificateText=($CertificateText | Out-String)
$resourceGroup="webandvm"
$vnetname="webandvm"
$defaultSubnetName="default"
$gatewaySubnetName="GatewaySubnet"
$gatewayName="pinttosite"



Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $subscriptionId
$vnet=Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -name $vnetname
$defaultSubnet=Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $defaultSubnetName
$gatewaySubnet=Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $gatewaySubnetName
$gateway=Get-AzureRmVirtualNetworkGateway -ResourceGroupName $resourceGroup -Name $gatewayName

$p2sRootCert= Add-AzureRmVpnClientRootCertificate -ResourceGroupName $resourceGroup -PublicCertData $CertificateText -VirtualNetworkGatewayName $gatewayName -VpnClientRootCertificateName $rootcertname

