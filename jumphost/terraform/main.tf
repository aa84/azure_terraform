provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "sonar" {
    name = "my_playground"
    location = "westeurope"
}

resource "azurerm_linux_virtual_machine" "sonarqube" {
    name = "sonarqube"
    size = "Standard_B1ms"
    admin_username = "alessandro"

    network_interface_ids = [
        azurerm_network_interface.sonarqube.id
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

resource "azurerm_network_interface" "sonarqube" {
    name = "nic"
    location = "westeurope"
    resource_group_name = "my_playground"
    ip_configuration {
        name = "internal"
        private_ip_address_allocation = "Static"
        subnet_id = azurerm_subnet.subnet1.id
        private_ip_address = "10.0.1.4"
        public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}

resource "azurerm_subnet" "subnet1" {
    name = "subnet1"
    resource_group_name = "my_playground"
    virtual_network_name = azurerm_virtual_network.vmnet.name

    address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_virtual_network" "vmnet" {
    name = "vmnet"
    resource_group_name = "my_playground"
    location = "westeurope"

    address_space = ["10.0.0.0/16"]
}


resource "azurerm_public_ip" "public_ip" {
    name = "public_ip"
    resource_group_name = "my_playground"
    allocation_method = "Dynamic"
    location = "westeurope"
    sku = "Basic"
}


resource "azurerm_network_security_group" "nsg" {
    name = "nsg"
    location = "westeurope"
    resource_group_name = "my_playground"

    security_rule {
        name = "allow80"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.sonarqube.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#######################################


module "jumphost" {
    source="./modules/jumphost"

    virtual_network_name = azurerm_virtual_network.vmnet.name
}