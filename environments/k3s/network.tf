resource "azurerm_virtual_network" "k3s" {
  name                = "vnet-k3s"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared.name
  address_space       = ["10.43.0.0/16"]
  tags                = var.tags
}

resource "azurerm_public_ip" "egress" {
  name                = "pip-k3s-egress"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [var.availability_zone]
  tags                = merge(var.tags, { Purpose = "outbound-only" })
}

resource "azurerm_nat_gateway" "k3s" {
  name                    = "nat-k3s"
  location                = var.location
  resource_group_name     = data.azurerm_resource_group.shared.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = [var.availability_zone]
  tags                    = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "k3s" {
  nat_gateway_id       = azurerm_nat_gateway.k3s.id
  public_ip_address_id = azurerm_public_ip.egress.id
}

resource "azurerm_subnet" "k3s" {
  name                            = "snet-k3s"
  resource_group_name             = data.azurerm_resource_group.shared.name
  virtual_network_name            = azurerm_virtual_network.k3s.name
  address_prefixes                = ["10.43.1.0/24"]
  default_outbound_access_enabled = false
  service_endpoints               = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

resource "azurerm_subnet_nat_gateway_association" "k3s" {
  subnet_id      = azurerm_subnet.k3s.id
  nat_gateway_id = azurerm_nat_gateway.k3s.id
}

resource "azurerm_network_security_group" "k3s" {
  name                = "nsg-k3s"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.shared.name
  tags                = var.tags

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "k3s" {
  subnet_id                 = azurerm_subnet.k3s.id
  network_security_group_id = azurerm_network_security_group.k3s.id
}

resource "azurerm_network_interface" "k3s" {
  name                           = "nic-k3s"
  location                       = var.location
  resource_group_name            = data.azurerm_resource_group.shared.name
  accelerated_networking_enabled = true
  tags                           = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.k3s.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.43.1.4"
  }

  depends_on = [
    azurerm_subnet_nat_gateway_association.k3s,
    azurerm_subnet_network_security_group_association.k3s,
  ]
}
