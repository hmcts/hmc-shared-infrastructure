
module "servicebus-namespace" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace?ref=master"
  name                = "${var.product}-servicebus-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  env                 = var.env
  common_tags         = local.tags
  sku                 = var.sku
  zoneRedundant       = (var.sku != "Premium" ? "false" : "true")
}

module "servicebus-queue" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=master"
  name                  = "${var.product}-to-hmi-${var.env}"
  namespace_name        = module.servicebus-namespace.name
  resource_group_name   = azurerm_resource_group.rg.name
}

module "servicebus-queue" {
  source                = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=master"
  name                  = "${var.product}-from-hmi-${var.env}"
  namespace_name        = module.servicebus-namespace.name
  resource_group_name   = azurerm_resource_group.rg.name
}