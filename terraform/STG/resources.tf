########## RG ########
resource "azurerm_resource_group" "rg_SelfHosted_Vm_un" {
  provider = azurerm.Sub-STG
  name     = "RG-STG-UN"
  location = "UAE North"
}

###### VNet ########
resource "azurerm_virtual_network" "vnet_SelfHosted_Vm_un" {
  provider            = azurerm.Sub-STG
  name                = "VNet-SelfHosted-STG"
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  address_space       = ["10.10.16.0/24","10.10.17.0/24"]
}

locals {
  VNet_subnets = {
    "SNet-Self-Hosted-STG" = "10.10.16.0/27"
    "SNet-Bastion-STG"     = "10.10.17.0/27"
  }
}

resource "azurerm_subnet" "VNet_subnets" {
  for_each             = local.VNet_subnets
  provider             = azurerm.Sub-STG
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  virtual_network_name = azurerm_virtual_network.vnet_SelfHosted_Vm_un.name
  address_prefixes     = [each.value]
}

########################
# Public IP
########################
resource "azurerm_public_ip" "SH_pip_un" {
  provider            = azurerm.Sub-STG
  name                = "PIP-SH-STG"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  allocation_method = "Static"
  sku               = "Standard"
}

########################
# NSG
########################
resource "azurerm_network_security_group" "SH_nsg_un" {
  provider            = azurerm.Sub-STG
  name                = "NSG-SH-STG"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

########################
# NIC
########################
resource "azurerm_network_interface" "SH_nic_un" {
  provider            = azurerm.Sub-STG
  name                = "NIC-SH-STG"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  ip_configuration {
    name                          = "ipconfig1STG"
    subnet_id                     = azurerm_subnet.VNet_subnets["SNet-Self-Hosted-STG"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.SH_pip_un.id
  }
}

resource "azurerm_network_interface_security_group_association" "SH_nic_nsg_un" {
  provider                  = azurerm.Sub-STG
  network_interface_id      = azurerm_network_interface.SH_nic_un.id
  network_security_group_id = azurerm_network_security_group.SH_nsg_un.id
}

########################
# Ubuntu VM
########################
resource "azurerm_linux_virtual_machine" "VM_Self_Hosted_un" {
  provider            = azurerm.Sub-STG
  name                = "VM_Self_Hosted-STG"

  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  size           = "Standard_D2_v3"
  admin_username = var.sh_vm_user
  admin_password = var.sh_vm_pass

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.SH_nic_un.id
  ]

  os_disk {
    name                 = "OSDisk-SH-STG"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name = "SelfHostedAgSTG"
}

########################
# Output
########################
output "SH_un_public_ip" {
  value       = azurerm_public_ip.SH_pip_un.ip_address
  description = "Connect to this IP"
}