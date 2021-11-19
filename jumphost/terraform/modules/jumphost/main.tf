


resource "azurerm_linux_virtual_machine" "main" {
    name = "jumphost-vm"
    size = "Standard_B1ms"
    admin_username = "alessandro"

    network_interface_ids = [
        azurerm_network_interface.main.id
    ]

    location = "westeurope"
    resource_group_name = "my_playground"

    os_disk {
        storage_account_type = "Standard_LRS"
        caching = "ReadWrite"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

     admin_ssh_key {
        username   = "alessandro"
        public_key = file("~/.ssh/id_rsa.pub")
    }
}

resource "azurerm_network_interface" "main" {
    name = "jumphost-nic"
    location = "westeurope"
    resource_group_name = "my_playground"
    ip_configuration {
        name = "internal"
        private_ip_address_allocation = "Dynamic"
        subnet_id = azurerm_subnet.main.id
        public_ip_address_id = azurerm_public_ip.main.id
    }
}

resource "azurerm_public_ip" "main" {
    name = "jumphost-pip"
    resource_group_name = "my_playground"
    allocation_method = "Dynamic"
    location = "westeurope"
    sku = "Basic"
}

resource "azurerm_subnet" "main" {
    name = "jumphost-sn"
    resource_group_name = "my_playground"
    virtual_network_name = var.virtual_network_name

    address_prefixes = ["10.0.2.0/24"]
}


resource "azurerm_network_security_group" "main" {
    name = "jumphost-nsg"
    location = "westeurope"
    resource_group_name = "my_playground"

    security_rule {
        name = "allow22"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}