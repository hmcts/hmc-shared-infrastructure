
module "servicebus-namespace" {
  providers = {
    azurerm.private_endpoint = azurerm.private_endpoint
  }
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace?ref=DTSPO-6371_remove_provider"
  name                = "${var.product}-servicebus-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  env                 = var.env
  common_tags         = local.tags
  sku                 = var.sku
  zone_redundant      = (var.sku != "Premium" ? "false" : "true")
}

module "servicebus-queue-request" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=DTSPO-6371_azurerm_upgrade"
  name                = "${var.product}-to-hmi-${var.env}"
  namespace_name      = module.servicebus-namespace.name
  resource_group_name = azurerm_resource_group.rg.name
}

module "servicebus-queue-response" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=DTSPO-6371_azurerm_upgrade"
  name                = "${var.product}-from-hmi-${var.env}"
  namespace_name      = module.servicebus-namespace.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "sb_primary_send_and_listen_connection_string" {
  value     = module.servicebus-namespace.primary_send_and_listen_connection_string
  sensitive = true
}

resource "azurerm_key_vault_secret" "servicebus_primary_connection_string" {
  name         = "hmc-servicebus-connection-string"
  value        = module.servicebus-namespace.primary_send_and_listen_connection_string
  key_vault_id = module.vault.key_vault_id
}

module "servicebus-topic" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-topic?ref=DTSPO-6371_azurerm_upgrade"
  name                = "${var.product}-to-cft-${var.env}"
  namespace_name      = module.servicebus-namespace.name
  resource_group_name = azurerm_resource_group.rg.name
}

module "servicebus-subscription" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-subscription?ref=DTSPO-6371_azurerm_upgrade"
  name                = "${var.product}-subs-to-cft-${var.env}"
  namespace_name      = module.servicebus-namespace.name
  topic_name          = module.servicebus-topic.name
  resource_group_name = azurerm_resource_group.rg.name
}
