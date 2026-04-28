########## RG ########
resource "azurerm_resource_group" "rg_SelfHosted_Vm_un" {
  provider = azurerm.Sub-TST
  name     = "RG-TST-UN"
  location = "UAE North"
}

###### VNet ########
resource "azurerm_virtual_network" "vnet_SelfHosted_Vm_un" {
  provider            = azurerm.Sub-TST
  name                = "VNet-SelfHosted-TST"
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  address_space       = ["10.10.16.0/23"]
}

locals {
  VNet_subnets = {
    "SNet-Self-Hosted-TST" = "10.10.16.0/27"
    "SNet-Bastion-TST"     = "10.10.17.0/27"
  }
}

resource "azurerm_subnet" "VNet_subnets" {
  for_each             = local.VNet_subnets
  provider             = azurerm.Sub-TST
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  virtual_network_name = azurerm_virtual_network.vnet_SelfHosted_Vm_un.name
  address_prefixes     = [each.value]
}

########################
# Public IP
########################
resource "azurerm_public_ip" "SH_pip_un" {
  provider            = azurerm.Sub-TST
  name                = "PIP-SH-TST"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  allocation_method = "Static"
  sku               = "Standard"
}

########################
# NSG
########################
resource "azurerm_network_security_group" "SH_nsg_un" {
  provider            = azurerm.Sub-TST
  name                = "NSG-SH-TST"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

########################
# NIC
########################
resource "azurerm_network_interface" "SH_nic_un" {
  provider            = azurerm.Sub-TST
  name                = "NIC-SH-TST"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  ip_configuration {
    name                          = "ipconfig1TST"
    subnet_id                     = azurerm_subnet.VNet_subnets["SNet-Self-Hosted-TST"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.SH_pip_un.id
  }
}

resource "azurerm_network_interface_security_group_association" "SH_nic_nsg_un" {
  provider                  = azurerm.Sub-TST
  network_interface_id      = azurerm_network_interface.SH_nic_un.id
  network_security_group_id = azurerm_network_security_group.SH_nsg_un.id
}

########################
# Ubuntu VM
########################
resource "azurerm_ubuntu_virtual_machine" "VM_Self_Hosted_un" {
  provider            = azurerm.Sub-TST
  name                = "VM_Self_Hosted-TST"

  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  size           = "Standard_D2_v3"
  admin_username = var.SH_VM_User
  admin_password = var.SH_VM_Pass

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.SH_nic_un.id
  ]

  os_disk {
    name                 = "OSDisk-SH-TST"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name = "SelfHostedAgTST"
}

########################
# Output
########################
output "SH_un_public_ip" {
  value       = azurerm_public_ip.SH_pip_un.ip_address
  description = "Connect to this IP using SSH on port 22"
}