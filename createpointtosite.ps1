cd \temp\cert

$subscriptionId="f19b7695-9685-461e-9700-2d9674197593"
$rootcertname="jmserverarootcert.cer"

$Text = Get-Content -Path "publicroot.cer"
$CertificateText = for ($i=1; $i -lt $Text.Length -1 ; $i++){$Text[$i]}
$CertificateText=($CertificateText | Out-String)
$resourceGroup="webandvm"
$vnetname=$resourceGroup
$defaultSubnetName="default"
$gatewayName="pointtosite"
$gatewaySubnetName="GatewaySubnet"# $gatewayName+"Subnet"
$GWIPName=$gatewayName+"Ip"
$GWIPconfName=$GWIPName+"Conf"
$VPNClientAddressPool="172.16.201.0/24"
$GWSubPrefix = "10.0.2.0/24"

Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $subscriptionId

$location= (Get-AzureRmResourceGroup -Name $resourceGroup).Location

$vnet=Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -name $vnetname
$defaultSubnet=Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $defaultSubnetName
Add-AzureRmVirtualNetworkSubnetConfig -Name $gatewaySubnetName -VirtualNetwork $vnet  -AddressPrefix $GWSubPrefix
#must apply the change
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
$vnet=Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -name $vnetname
$gwsub=Get-AzureRmVirtualNetworkSubnetConfig -Name $gatewaySubnetName -VirtualNetwork $vnet

$pip = New-AzureRmPublicIpAddress -Name $GWIPName -ResourceGroupName $resourceGroup -Location $location -AllocationMethod Dynamic$ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName -SubnetId $gwsub.Id -PublicIpAddressId $pip.Id


$p2srootcert = New-AzureRmVpnClientRootCertificate -Name $rootcertname -PublicCertData $CertificateText
New-AzureRmVirtualNetworkGateway -Name $gatewayName -ResourceGroupName $resourceGroup -Location $location -IpConfigurations $ipconf -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Basic -VpnClientAddressPool $VPNClientAddressPool -VpnClientRootCertificates $p2srootcert

