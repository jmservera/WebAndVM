cd \temp\cert

$subscriptionId="f19b7695-9685-461e-9700-2d9674197593"
$rootcertname="jmserverarootcert.cer"

$Text = Get-Content -Path "publicroot.cer"
$CertificateText = for ($i=1; $i -lt $Text.Length -1 ; $i++){$Text[$i]}
$CertificateText=($CertificateText | Out-String)
$resourceGroup="webandvm"
$vnetname="webandvm"
$defaultSubnetName="default"
$gatewayName="pointtosite"
$gatewaySubnetName=$gatewayName+"Subnet"
$GWIPName=$gatewayName+"Ip"
$GWIPconfName=$GWIPName+"Conf"
$VPNClientAddressPool="172.16.201.0/24"
$GWSubPrefix = "192.168.200.0/26"

Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionId $subscriptionId

$location= (Get-AzureRmResourceGroup -Name $resourceGroup).Location

$vnet=Get-AzureRmVirtualNetwork -ResourceGroupName $resourceGroup -name $vnetname
$defaultSubnet=Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $defaultSubnetName
$gwsub=Add-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $gatewaySubnetName -AddressPrefix $GWSubPrefix -Verbose

$pip = New-AzureRmPublicIpAddress -Name $GWIPName -ResourceGroupName $resourceGroup -Location $location -AllocationMethod Dynamic$ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName -SubnetId $gwsub.Id -PublicIpAddressId $pip.Id

$p2srootcert = New-AzureRmVpnClientRootCertificate -Name $rootcertname -PublicCertData $CertificateText
$gateway= New-AzureRmVirtualNetworkGateway -Name $gatewayName -ResourceGroupName $resourceGroup -Location $location -IpConfigurations $ipconf -GatewayType Vpn -VpnType RouteBased -EnableBgp $false -GatewaySku Standard -VpnClientAddressPool $VPNClientAddressPool -VpnClientRootCertificates $p2srootcert

