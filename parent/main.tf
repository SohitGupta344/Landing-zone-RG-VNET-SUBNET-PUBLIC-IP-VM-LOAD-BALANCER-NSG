module "resource_group" {
  source   = "../modules/resource_group"
  name     = "sep07rg"
  location = "Korea Central"
}
module "vnet" {
depends_on = [ module.resource_group ]
  source              = "../modules/vnet"
  name                = "sep07vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "Korea Central"
  resource_group_name = "sep07rg"
}
module "subnet_vm01" {
depends_on = [ module.vnet , module.resource_group ]
  source               = "../modules/subnet"
  name                 = "vmsubnet01"
  resource_group_name  = "sep07rg"
  virtual_network_name = "sep07vnet"
  address_prefixes     = ["10.0.1.0/24"]
}

module "subnet_vm02" {
depends_on           = [ module.vnet , module.resource_group ]
  source               = "../modules/subnet"
  name                 = "vmsubnet02"
  resource_group_name  = "sep07rg"
  virtual_network_name = "sep07vnet"
  address_prefixes     = ["10.0.2.0/24"]
}

module "subnet_bastion_subnet" {
    depends_on = [ module.vnet , module.resource_group ]
  source               = "../modules/subnet"
  name                 = "AzureBastionSubnet"
  resource_group_name  = "sep07rg"
  virtual_network_name = "sep07vnet"
  address_prefixes     = ["10.0.3.0/24"]
}

module "public_ip_lb" {
    depends_on = [ module.vnet , module.resource_group ]
  source              = "../modules/public_ip"
  name                = "lb-pip"
  location            = "Korea Central"
  resource_group_name = "sep07rg"
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "public_ip_bastion" {
    depends_on = [ module.subnet_bastion_subnet ]
  source              = "../modules/public_ip"
  name                = "bastion-pip"
  location            = "Korea Central"
  resource_group_name = "sep07rg"
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "lb" {
    depends_on = [ module.resource_group, module.public_ip_lb ]
  source              = "../modules/load_balancer"
  name                = "sep07lb"
  location            = "Korea Central"
  resource_group_name = "sep07rg"
  sku                 = "Standard"
  frontend_name       = "lb-frontend"
  public_ip_id        = module.public_ip_lb.id
  backend_pool_name   = "lb-backend-pool"
  probe_name          = "lb-probe"
  probe_port          = 80
  rule_name           = "lb-rule"
  frontend_port       = 9066
  backend_port        = 80
}

module "vm_app1" {
    depends_on = [ module.subnet_vm01 ]
  source              = "../modules/vm"
  nic_name            = "nic-vm01"
  location            = "Korea Central"
  resource_group_name = "sep07rg"
  subnet_id           = module.subnet_vm01.id
  public_ip_id        = null
  vm_name             = "vm01"
  vm_size             = "Standard_B1s"
  admin_username      = "sohitgupta"
  admin_password      = "Sohiitgupta10@@"
  lb_backend_pool_id  = module.lb.bap_id
}

module "vm_app2" {
    depends_on = [ module.subnet_vm02 ]
  source              = "../modules/vm"
  nic_name            = "nic-vm02"
  location            = "Korea Central"
  resource_group_name = "sep07rg"
  subnet_id           = module.subnet_vm02.id
  public_ip_id        = null
  vm_name             = "vm02"
  vm_size             = "Standard_B1s"
  admin_username      = "sohitgupta"
  admin_password      = "Sohiitgupta10@@"
  lb_backend_pool_id  = module.lb.bap_id
}

module "bastion" {
    depends_on = [ module.vnet, module.subnet_bastion_subnet, module.public_ip_bastion]
  source              = "../modules/bastion"
  name                = "bastion"
  location            = "Korea Central"
  resource_group_name = "sep07rg"
#   dns_name            = "Configuration"
  subnet_id           = module.subnet_bastion_subnet.id
  public_ip_id        = module.public_ip_bastion.id
}

module "nsg_vm01" {
  source              = "../modules/nsg"
  name                = "nsg-vm01"
  location            = "Korea Central"
  resource_group_name = "sep07rg"
}

module "nsg_vm02" {
  source              = "../modules/nsg"
  name                = "nsg-vm02"
  location            = "Korea Central"
  resource_group_name = "sep07rg"
}

resource "azurerm_subnet_network_security_group_association" "vm01_nsg_assoc" {
  subnet_id                 = module.subnet_vm01.id
  network_security_group_id = module.nsg_vm01.id
}

resource "azurerm_subnet_network_security_group_association" "vm02_nsg_assoc" {
  subnet_id                 = module.subnet_vm02.id
  network_security_group_id = module.nsg_vm02.id
}
