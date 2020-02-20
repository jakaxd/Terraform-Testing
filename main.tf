terraform {
  backend "azurerm" {
    resource_group_name   = "Terraform"
    storage_account_name  = "devopsterraform123"
    container_name        = "terraform"
    key                   = "terraform.tfstate"
    access_key            = "ZmEAb7UteQW2DL6ua9LPfymKHhDPzkyZrPjnYB9m3l+Hcnwar0AFqGOicVpLGwYI7IP1kSwSSFDE0ltKjieSjw=="
  }
}
provider "azurerm" {
    version = "~> 1.0"
    subscription_id = "21544ffb-6216-4095-8d3b-bb544b0d6337"
    client_id = "a760b8c0-2be0-4ef7-a992-00c288108c68"
    client_secret = "RFqS9sstIJ[W8]enP81DfNPQBimq_OH/"
    tenant_id = "a986295b-298e-494f-ac36-e45633c3c2c1"
}
#########################################################################################################
/////////////////////////////////////// Resource Group //////////////////////////////////////////////////
#########################################################################################################
resource "azurerm_resource_group" "rg" {
  name     = "__resource_group_name__"
  location = "__location__"
}
#########################################################################################################
///////////////////////////////////////// Networking ////////////////////////////////////////////////////
#########################################################################################################
resource "azurerm_virtual_network" "vnet" {
  name                = "__VNet_name__"
  location            = "__location__"
  resource_group_name = "__resource_group_name__"
  address_space       = ["${var.addressspace}"]
  dns_servers         = ["10.0.1.4"]
}
resource "azurerm_public_ip" "public-ip" {
  name = "${var.prefix}-Frontend1"
  location = "__location__"
  resource_group_name = "__resource_group_name__"
  allocation_method = "Static"
}
resource "azurerm_public_ip" "public-ip2" {
  name = "${var.prefix}-Frontend2"
  location = "__location__"
  resource_group_name = "__resource_group_name__"
  allocation_method = "Static"
}
resource "azurerm_subnet" "subnet" {
  name                      = "__subnet_name__"
  resource_group_name       = "__resource_group_name__"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${var.addressprefix}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}
resource "azurerm_network_interface" "vm01" {
  name                            = "__dc_nic_name__"
  location                        = "__location__"
  resource_group_name             = "__resource_group_name__"
  dns_servers                     = ["10.0.1.4"]
    ip_configuration {
    name                          = "${var.nicname}"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address            = var.private_ip1
    private_ip_address_allocation = "static"
    public_ip_address_id          = "${azurerm_public_ip.public-ip.id}"
  }
}
resource "azurerm_network_interface" "vm02" {
  name                            = "__dc2_nic_name__"
  location                        = "__location__"
  resource_group_name             = "__resource_group_name__"
  dns_servers                     = ["10.0.1.4"]
  ip_configuration {
    name                          = "${var.nic2name}"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address            = var.private_ip2
    private_ip_address_allocation = "static"
    public_ip_address_id          = "${azurerm_public_ip.public-ip2.id}"
  }
}
#########################################################################################################
////////////////////////////////////// Network Security /////////////////////////////////////////////////
#########################################################################################################
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.nsg}"
  location            = "__location__"
  resource_group_name = "__resource_group_name__"
}
resource "azurerm_network_security_rule" "nsgrule" {
  name                        = "Inbound-RDP"
  priority                    = 200
  direction                   = "inbound"
  access                      = "allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "__resource_group_name__"
  network_security_group_name = "${azurerm_network_security_group.nsg.name}"
}
resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = "${azurerm_subnet.subnet.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}
#########################################################################################################
///////////////////////////////////////// Create VM /////////////////////////////////////////////////////
#########################################################################################################
resource "azurerm_virtual_machine" "vm" {
  name                  = "__vm1name__"
  location              = "__location__"
  resource_group_name   = "__resource_group_name__"
  network_interface_ids = ["${azurerm_network_interface.vm01.id}"]
  vm_size               = "${var.vmsize}"
  storage_image_reference {
    publisher           = "MicrosoftWindowsServer"
    offer               = "WindowsServer"
    sku                 = "2016-Datacenter"
    version             = "latest"
  }
  storage_os_disk {
    name              = "server-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "VM01"
    admin_username = "${var.adminusername}"
    admin_password = "${var.adminpass}"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = "true"
    provision_vm_agent = "true"
  }
}
resource "azurerm_virtual_machine" "vm02" {
  name                  = "__vm2name__"
  location              = "__location__"
  resource_group_name   = "__resource_group_name__"
  network_interface_ids = ["${azurerm_network_interface.vm02.id}"]
  vm_size               = "${var.vmsize}"
  storage_image_reference {
    publisher           = "MicrosoftWindowsServer"
    offer               = "WindowsServer"
    sku                 = "2016-Datacenter"
    version             = "latest"
  }
  storage_os_disk {
    name              = "server-os2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "VM02"
    admin_username = "${var.adminusername}"
    admin_password = "${var.adminpass}"
  }
  os_profile_windows_config {
    enable_automatic_upgrades = "true"
    provision_vm_agent = "true"
  }
}
#########################################################################################################
//////////////////////////////////// Create/Join to Domain //////////////////////////////////////////////
#########################################################################################################
resource "azurerm_virtual_machine_extension" "create-active-directory-forest" {
  name                 = "create-active-directory-forest"
  location             = "__location__"
  resource_group_name  = "__resource_group_name__"
  virtual_machine_id   = "${azurerm_virtual_machine.vm.id}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -Command \"${local.powershell_command}\""
    }
SETTINGS
}
resource "azurerm_virtual_machine_extension" "join-active-directory-forest" {
  name = "join-domain"
  location = "__location__"
  resource_group_name = "__resource_group_name__"
  virtual_machine_name = "${azurerm_virtual_machine.vm02.name}"
  publisher = "Microsoft.Compute"
  type = "JsonADDomainExtension"
  type_handler_version = "1.3"
  settings = <<SETTINGS
{
"Name": "${var.active_directory_domain}",
"OUPath": "",
"User": "jellybeantest\\azureadmin",
"Restart": "true",
"Options": "3"
}
SETTINGS
protected_settings = <<PROTECTED_SETTINGS
{
"Password": "${var.adminpass}"
}
PROTECTED_SETTINGS
depends_on = ["azurerm_virtual_machine_extension.create-active-directory-forest"]
}