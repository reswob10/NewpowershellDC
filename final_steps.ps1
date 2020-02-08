
#######  !!!!!!!!!!!! ATTENTION  !!!!!!!!!!!!!!!!!
####
#### Make sure you edit and replace all the < brackets and text between the brackets  > 
#### 
###### !!!!!!!!!!  ATTENTION  !!!!!!!!!!!!!!


#### !!!!!!!!!!!!!!! ATTENTION  !!!!!!!!!!!!!!!!!
# make sure you edit what OUs you want starting about line 73 below !!!!!!!
#### !!!!!!!!!!!!!!! ATTENTION  !!!!!!!!!!!!!!

# Creating a domain account with domain admin access through powershell
New-ADUser -Name <name of domain admin> -GivenName <domain admin first name> -Surname <domain admin last name> -SamAccountName <username of domain admin> -UserPrincipalName <user name plus domain. example: jones@test.local>

$password1 = "<password for domain admin>"| ConvertTo-SecureString -AsPlainText -Force

Set-ADAccountPassword ‘CN=<username of domain admin>,CN=users,DC=xxxxx,DC=xxxxx’ -Reset -NewPassword $password1

Enable-ADAccount -Identity <username of domain admin>

#  If your DNS server is not installed, you can install it with this command:

Install-WindowsFeature DNS -IncludeManagementTools

#  The DNS primary zone is created when the forest is generated. Next, the network ID and file entry is made:

Add-DnsServerPrimaryZone -NetworkID $dnszoneID <network of DNS zone CIDR notation. ex: 192.168.1.0/24) -ZoneFile "<reverse lookup for zone. ex: 192.168.64.2.in-addr.arpa.dns>"

#  Next, the forwarder is added:

Add-DnsServerForwarder -IPAddress <IP of DNS server. ex: 8.8.8.8> -PassThru

#  We’ll begin by installing the DHCP role. To do this, the Windows 2016 Sever must be configured with a static IP address. 

Install-WindowsFeature DHCP -IncludeManagementTools
#  set security groups
netsh dhcp add securitygroups
#  add scopes
Add-DHCPServerv4Scope -Name “Employee Scope” -StartRange <IP to start range of DHCP> -EndRange <IP to end range of DHCP> -SubnetMask <subnet mask to be given to all DHCP clients> -State Active

#  set lease duration
Set-DhcpServerv4Scope -ScopeId <The ID scope of the DHCP. ex: 192.168.1.0> -LeaseDuration 1.00:00:00

#  Next, authorize the DHCP server to operate in the domain:

Set-DHCPServerv4OptionValue -ScopeID <The ID scope of the DHCP. ex: 192.168.1.0> -DnsDomain <The domain. ex: test.local> -DnsServer <IP of the DNS server.  Should be the IP you used at step 1> -Router <IP of the gateway>

#  DHCP Server is added to the DC:

Add-DhcpServerInDC -DnsName <The domain. ex: test.local> -IpAddress <IP of the DNS server.  Should be the IP you used at step 1> 

#  We can verify the DHCP Scope setting using this command:
#Get-DhcpServerv4Scope

Restart-service dhcpserver

# Import active directory module for running AD cmdlets
Import-Module activedirectory

# Create OU
# Duplicate this line and modify as many times as you want to create OUs.
# Else comment it out if you do not want to create OUs.


NEW-ADOrganizationalUnit "<name here>" –path “DC=XXXXX,DC=XXXXX”



# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
# Using the csv file, create users.  
#### !!!!!!!!!!!!!!1   ATTENTION  !!!!!!!!!!!!!!!!!!!
#### Make sure you edit the csv with the correct domain information prior to running this file.  
#### The domain information should match you created above with the second script.  
####   That is also the $dhcpdnsdomain variable above
####  !!!!!!!!!!!  ATTENTION  !!!!!!!!!!!!!!!!


#Store the data from AD Users csv in the $ADUsers variable
$ADUsers = Import-csv C:\tools\bulk_users2.csv

#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
	
	$Username 	= $User.username
	write-output $Username
	$Password 	= $User.password
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
	$OU 		= $User.ou #This field refers to the OU the user account is to be created in
    $Password = $User.Password


	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
	New-ADUser -SamAccountName $Username -UserPrincipalName "$Username@scouts.local" -GivenName $Firstname -Name "$Firstname $Lastname"  -Surname $Lastname -Enabled $True  -DisplayName "$Lastname, $Firstname" -Path $OU -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $False            
	}
}

# Install sysmon64 with swift on security config
$command = 'c:\tools\Sysmon64.exe -accepteula -i c:\tools\swift_sysmon_config.xml'
iex $command

# Enable Windows Driver Framework
# This log tracks all USB devices plugged in

$logName = 'Microsoft-Windows-DriverFrameworks-UserMode/Operational'
$log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
$log.IsEnabled=$true # change to $false if disabling
$log.SaveChanges() 

# Enable Windows DNS Analytical
# This is the new DNS logging.  Much faster and less load than DNS Debug logging

$logName1 = 'Microsoft-Windows-DNSServer/Analytical'
$log1 = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName1
$log1.IsEnabled=$true # change to $false if disabling
$log1.SaveChanges() 
