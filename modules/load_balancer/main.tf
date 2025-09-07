resource "azurerm_lb" "lb" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  frontend_ip_configuration {
    name                 = var.frontend_name
    public_ip_address_id = var.public_ip_id
  }
}

resource "azurerm_lb_backend_address_pool" "bap" {
  name                = var.backend_pool_name
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name                = var.probe_name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = var.probe_port
}

resource "azurerm_lb_rule" "lb-rule" {
  name                           = var.rule_name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                      = "Tcp"
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = var.frontend_name
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.bap.id]
  probe_id                       = azurerm_lb_probe.probe.id
}
