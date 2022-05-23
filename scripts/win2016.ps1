# Basic configuration of vanilla Windows Server installation to progress Packer.io builds
# @author Michael Poore
# @website https://blog.v12n.io
# @source https://github.com/virtualhobbit
$ErrorActionPreference = "Stop"

# Switch network connection to private mode
# Required for WinRM firewall rules
$profile = Get-NetConnectionProfile
Set-NetConnectionProfile -Name $profile.Name -NetworkCategory Private

# Enable WinRM service
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

#Configure NIC as Env has no DHCP
$netadapter = Get-NetAdapter -Name Ethernet0
## Disable DHCP
$netadapter | Set-NetIPInterface -DHCP Disabled
## Configure the IP address and default gateway for "VM Network" in Env
$netadapter | New-NetIPAddress -AddressFamily IPv4 -IPAddress 10.59.93.15 -PrefixLength 24 -Type Unicast -DefaultGateway 10.59.93.1
## Configure the DNS servers
Set-DnsClientServerAddress -InterfaceAlias Ethernet0 -ServerAddresses ("10.30.15.200","10.30.55.200")
