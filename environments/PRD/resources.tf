
########## RG ########
resource "azurerm_resource_group" "rg_SelfHosted_Vm_un" {
  provider = azurerm.Sub-PRD
  name     = "RG-PRD-UN"
  location = "UAE North"
}


###### VNet ########
resource "azurerm_virtual_network" "vnet_SelfHosted_Vm_un" {
  provider            = azurerm.Sub-PRD
  name                = "VNet-SelfHosted-PRD"
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  address_space       = ["10.10.16.0/24"]
}

# Identity Subnets
locals {
  VNet_subnets = {
    "SNet-Self-Hosted-PRD" = "10.10.16.0/27"
    "SNet-Bastion-PRD"     = "10.10.17.0/27"


  }
}

resource "azurerm_subnet" "VNet_subnets" {
  for_each             = local.VNet_subnets
  provider             = azurerm.Sub-PRD
  name                 = each.key
  resource_group_name  = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  virtual_network_name = azurerm_virtual_network.vnet_SelfHosted_Vm_un.name
  address_prefixes     = [each.value]
}

#### VM   ##########

########################
# Public IP
########################
resource "azurerm_public_ip" "SH_pip_un" {
  provider            = azurerm.Sub-PRD
  name                = "PIP-SH-PRD"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  allocation_method = "Static"
  sku               = "Standard"
}

########################
# NSG SH_VM Box
########################
resource "azurerm_network_security_group" "SH_nsg_un" {
  provider            = azurerm.Sub-PRD
  name                = "NSG-SH-PRD"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  security_rule {
    name                   = "Allow-RDP"
    priority               = 1000
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "Tcp"
    source_port_range      = "*"
    destination_port_range = "3389"


    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

########################
# NIC SNet-MGMT-UN
########################
resource "azurerm_network_interface" "SH_nic_un" {
  provider            = azurerm.Sub-PRD
  name                = "NIC-SH-PRD"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  ip_configuration {
    name                          = "ipconfig1PRD"
    subnet_id                     = azurerm_subnet.hub_subnets["SNet-Self-Hosted-PRD"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.SH_pip_un.id
  }
}

resource "azurerm_network_interface_security_group_association" "SH_nic_nsg_un" {
  provider                  = azurerm.Sub-PRD
  network_interface_id      = azurerm_network_interface.SH_nic_un.id
  network_security_group_id = azurerm_network_security_group.SH_nsg_un.id
}

########################
# Windows Jump Box VM
########################
resource "azurerm_ubuntu_virtual_machine" "VM_Self_Hosted_un" {
  provider            = azurerm.Sub-PRD
  name                = "VM_Self_Hosted-STG"

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
    name                 = "OSDisk-SH-PRD"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name = "SelfHostedAgPRD"
}

########################
# Output
########################
output "SH_un_public_ip" {
  value       = azurerm_public_ip.SH_pip_un.ip_address
  description = "Connect to this IP"
}