# make sure the DC had a statis IP and DNS set before running this script

#######  !!!!!!!!!!!! ATTENTION  !!!!!!!!!!!!!!!!!
####
#### Make sure you edit and replace all the < brackets and text between the brackets  > 
#### 
###### !!!!!!!!!!  ATTENTION  !!!!!!!!!!!!!!

New-NetIPAddress -InterfaceIndex (Get-NetAdapter).InterfaceIndex -IPAddress <enter IP here> -PrefixLength <enter netmask here> -DefaultGateway <enter gateway IP here>

Rename-Computer -NewName "<enter hostname here. must keep within quotes>" -Force

restart-computer