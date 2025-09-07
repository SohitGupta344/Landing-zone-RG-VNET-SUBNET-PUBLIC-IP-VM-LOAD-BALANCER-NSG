# NIC
resource "azurerm_network_interface" "sep07_nic" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}


resource "azurerm_network_interface_backend_address_pool_association" "vm1_lb_assoc" {
  network_interface_id    = azurerm_network_interface.sep07_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.lb_backend_pool_id
}


resource "azurerm_linux_virtual_machine" "sep07_vm" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.sep07_nic.id]
  disable_password_authentication = false
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.vm_name}-osdisk"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install nginx -y
    systemctl enable nginx
    systemctl start nginx
    echo "<h1>Welcome to Sohit Gupta Thanx for creating this module approach ${var.vm_name}</h1>" > /var/www/html/index.html
  EOT
  )

  

  
}

