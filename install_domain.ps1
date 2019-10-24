
#######  !!!!!!!!!!!! ATTENTION  !!!!!!!!!!!!!!!!!
####
#### Make sure you edit and replace all the < brackets and text between the brackets  > 
#### 
###### !!!!!!!!!!  ATTENTION  !!!!!!!!!!!!!!

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
 
$password = "<enter password here. Make it strong>" | ConvertTo-SecureString -AsPlainText -Force

Install-ADDSForest -DomainName "<create domain name here. example: test.local>" -SafeModeAdministratorPassword $password -Force

