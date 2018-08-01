# Perform the below using Powershell as Admnistrator

# Modify to match the VPC DNS IP
$VPCDNS = "172.17.1.2"
$Name = "DNS-Server"
$OnPremDNS = "10.0.0.1,10.0.0.2"
$DNSSuffix = "ec2.internal"
$ZoneForward = "onprem.local"
$ZoneReverse = "10.in-addr.arpa"

# Install DNS ServerAddresses
Install-WindowsFeature -Name DNS -IncludeAllSubFeature -IncludeManagementTools

# Set DNS Forwarder and do not use root hints
Add-DnsServerForwarder -IPAddress $VPCDNS -PassThru
Set-DnsServerForwarder -UseRootHint $false

# Create Conditional Zones
Add-DnsServerConditionalForwarderZone -Name $ZoneForward -MasterServers $OnPremDNS -PassThru
Add-DnsServerConditionalForwarderZone -Name $ZoneReverse -MasterServers $OnPremDNS -PassThru

#Update primary DNS Suffix for FQDN
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name Domain -Value $DNSSuffix
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\" -Name "NV Domain" -Value $DNSSuffix

# Rename Computer and Restart
Rename-Computer -NewName $Name -Restart -PassThru -Force


