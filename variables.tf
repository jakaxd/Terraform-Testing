# Variables
variable "prefix" {
    default = "TF"
    description = "Specify a prefix, before naming a resource"
}
variable "location" {
    default = "UKSouth"
    description = "Default Region where the resources should be located"
}
variable "addressspace" {
    default = "10.0.0.0/16"
    description = "Virtual Network Address Space"
}
variable "addressprefix" {
    default = "10.0.1.0/24"
    description = "Subnet Address Space"
}
variable "nicname" {
    default = "NIC"
    description = "Specify the name of the NIC"
}
variable "nic2name" {
    default = "NIC2"
    description = "Specify the name of the NIC"
}
variable "private_ip1" {
    type = string
    default = "10.0.1.4"
    description = "Specify the IP address"
}
variable "private_ip2" {
    type = string
    default = "10.0.1.5"
    description = "Specify the IP address"
}
variable "nsg" {
    default = "NSG-001"
    description = "Specify the name of the Network Security Group"
}
variable "vmname" {
    default = "VM01"
    description = "Specify the name of the Virtual Machine"
}
variable "vm02name" {
    default = "VM02"
    description = "Specify the name of the Virtual Machine"
}
variable "vmsize" {
    default = "Standard_B2ms"
    description = "Specify the size of the VM"
}
variable "adminpass" {
    default = "Passw0rd1234!"
    description = "Specify the password for the Administrator account"
}
variable "adminusername" {
    default = "azureadmin"
    description = "Specify the username for the Administrator account"
}
variable "vm_name" {
    default = "VM01"
    description = "The Virtual Machine name that you wish to join to the domain"
}
variable "active_directory_domain" {
    default = "Jellybeantest.org"
    description = "The name of the Active Directory domain, for example `consoto.local`"
}
variable "admin_password" {
    default = "Passw0rd1234!"
    description = "The password associated with the local administrator account on the virtual machine"
}
variable "active_directory_netbios_name" {
    default = "jellybeantest"
    description = "The netbios name of the Active Directory domain, for example `consoto`"
}
locals { 
  import_command       = "Import-Module ADDSDeployment"
  password_command     = "$password = ConvertTo-SecureString ${var.admin_password} -AsPlainText -Force"
  install_ad_command   = "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools"
  configure_ad_command = "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode WinThreshold -DomainName ${var.active_directory_domain} -DomainNetbiosName ${var.active_directory_netbios_name} -ForestMode WinThreshold -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
  shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  powershell_command   = "${local.import_command}; ${local.password_command}; ${local.install_ad_command}; ${local.configure_ad_command}; ${local.shutdown_command}; ${local.exit_code_hack}"
}