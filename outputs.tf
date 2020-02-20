output "network_interfact_id" {
  value = "${azurerm_network_interface.vm01.id}"
}
output "network_interfact_id2" {
  value = "${azurerm_network_interface.vm02.id}"
}
output "subnet_subnet_ids" {
  value = "${azurerm_subnet.subnet.id}"
}
output "public_ip_address" {
  value = "${azurerm_public_ip.public-ip.id}"
}
output "virtual_machine_id" {
  value = "${azurerm_virtual_machine.vm.id}"
}
output "network_security_group_id" {
  value = "${azurerm_network_security_group.nsg.id}"
}