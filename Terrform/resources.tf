
########## RG ########
resource "azurerm_resource_group" "rg_SelfHosted_Vm_un" {
  provider = azurerm.Sub-TST
  name     = "RG-TST-UN"
  location = "UAE North"
}


###### VNet ########
resource "azurerm_virtual_network" "vnet_SelfHosted_Vm_un" {
  provider            = azurerm.Sub-TST
  name                = "VNet-SelfHosted-Vm-UN"
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  address_space       = ["10.10.16.0/24"]
}

# Identity Subnets
locals {
  VNet_subnets = {
    "SNet-Self-Hosted-UN" = "10.10.16.0/27"
    "SNet-Bastion-UN"     = "10.10.17.0/27"


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

#### VM   ##########

########################
# Public IP
########################
resource "azurerm_public_ip" "SH_pip_un" {
  provider            = azurerm.Sub-TST
  name                = "PIP-JumpBox-UN"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  allocation_method = "Static"
  sku               = "Standard"
}

########################
# NSG SH_VM Box
########################
resource "azurerm_network_security_group" "SH_nsg_un" {
  provider            = azurerm.Sub-TST
  name                = "NSG-SH-UN"
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
  provider            = azurerm.Sub-TST
  name                = "NIC-SH-UN"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hub_subnets["SNet-Self-Hosted-UN"].id
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
# Windows Jump Box VM
########################
resource "azurerm_windows_virtual_machine" "VM_Self_Hosted_un" {
  provider            = azurerm.Sub-TST
  name                = "VM_Self_Hosted-UN"
  resource_group_name = azurerm_resource_group.rg_SelfHosted_Vm_un.name
  location            = azurerm_resource_group.rg_SelfHosted_Vm_un.location

  size           = "Standard_D2_v3" # 
  admin_username = var.SH_VM_User
  admin_password = var.SH_VM_Pass # pull password from key vault

  network_interface_ids = [
    azurerm_network_interface.SH_nic_un.id
  ]


  os_disk {
    name                 = "OSDisk-SH-UN"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Windows Server OS only
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name = "SelfHostedAgent"
}

########################
# Output Public IP
########################
output "SH_un_public_ip" {
  value       = azurerm_public_ip.SH_pip_un.ip_address
  description = "RDP to this IP on port 3389"
}