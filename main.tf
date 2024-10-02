terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }
  }
}


resource "azurerm_resource_group" "rg_irtech" {
  name     = "rg-irtech"
  location = "East US"
  tags = {
    environment = "dev"
  }

}

resource "azurerm_resource_group" "rg_desco" {
  name     = "rg-desco"
  location = "East US"
  tags = {
    environment = "dev"
  }

}

resource "azurerm_resource_group" "rg_irtech_dev" {
  name     = "rg-irtech-dev"
  location = "East US"
  tags = {
    environment = "dev"
  }

}
resource "azurerm_resource_group" "rg_irtech_prod" {
  name     = "rg-irtech-prod"
  location = "East US"
  tags = {
    environment = "prod"
  }

}

resource "azurerm_resource_group" "rg_hc_prod" {
  name     = "rg-hc-prod"
  location = "East US"
  tags = {
    environment = "prod"
  }

}

resource "azurerm_virtual_network" "vnet_desco" {
  name                = "vnet-desco"
  location            = "East US"
  resource_group_name = "rg-desco"
  address_space       = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]

  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "subnet_ext_dmz_irtech_0" {
  name                 = "subnet-ext-dmz-irtech-0"
  resource_group_name  = "rg-desco"
  virtual_network_name = "vnet-desco"
  address_prefixes     = ["192.168.10.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}


resource "azurerm_network_security_group" "sg_vnet-desco" {
  name                = "nsg-vnet-desco"
  location            = azurerm_resource_group.rg_desco.location
  resource_group_name = azurerm_resource_group.rg_desco.name
}

resource "azurerm_network_security_rule" "sr_allow-inbound-access" {

  name                        = "sr-allow-inbound-access"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg_desco.name
  network_security_group_name = azurerm_network_security_group.sg_vnet-desco.name
}

resource "azurerm_subnet_network_security_group_association" "snsga_subnet-ext-dmz-irtech-0_sg-vnet-desco" {
  subnet_id                 = azurerm_subnet.subnet_ext_dmz_irtech_0.id
  network_security_group_id = azurerm_network_security_group.sg_vnet-desco.id
}







