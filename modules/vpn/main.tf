resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  sku {
    name = "VpnGw1"
    tier = "VpnGw1"
  }

  ip_configuration {
    name                          = "vpngateway-ipconf"
    public_ip_address_id          = var.public_ip_id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
}

output "vpn_gateway_id" {
  value = azurerm_virtual_network_gateway.vpn_gateway.id
}