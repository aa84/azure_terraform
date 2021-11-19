output "webvm_public_ip" {
    value = azurerm_public_ip.public_ip.ip_address
}

output "jumphost_public_ip" {
    value = module.jumphost.ip_address
}