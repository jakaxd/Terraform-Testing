resource "azurerm_resource_group" "rg" {
    name = __resourcegroupname__
    location = __location__
}
resource "azurerm_virtual_network" "vnet" {
    name = __vnetname__
    location = __location__
    resource_group_name = __resourcegroupname__
    address_space = __addressspace__
}
