# Create a resource group
resource "azurerm_resource_group" "k8s_resource_group" {
  name     = "k8s-resource-group"
  location = "${var.region}"
}

resource "azurerm_virtual_network" "k8s_vnet" {
  name                = "k8s-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.k8s_resource_group.location
  resource_group_name = azurerm_resource_group.k8s_resource_group.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.k8s_resource_group.name
  virtual_network_name = azurerm_virtual_network.k8s_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# create a public ip
resource "azurerm_public_ip" "k8s_worker_public_ip" {
    name = "k8s-worker-public-ip"
    location = azurerm_resource_group.k8s_resource_group.location
    resource_group_name = azurerm_resource_group.k8s_resource_group.name
    allocation_method = "Dynamic"
    tags = {
        name = "k8s-worker-public-ip"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "allow_all" {
  name                = "allow-all"
  location            = azurerm_resource_group.k8s_resource_group.location
  resource_group_name = azurerm_resource_group.k8s_resource_group.name

  security_rule {
    name                       = "allow-all"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    name = "allow-all"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.k8s_resource_group.location
  resource_group_name = azurerm_resource_group.k8s_resource_group.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.k8s_worker_public_ip.id
  }

  tags = {
    name = "nic"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.allow_all.id
}


# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "k8s_worker" {
  name                  = "k8s-worker"
  location              = azurerm_resource_group.k8s_resource_group.location
  resource_group_name   = azurerm_resource_group.k8s_resource_group.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2"

 os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8"
    version   = "8.0.20191023"
  }

  computer_name                   = "worker"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
    
  }

  tags = {
    name = "worker"
  }
}
