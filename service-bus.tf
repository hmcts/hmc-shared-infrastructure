
module "servicebus-namespace" {
  providers = {
    azurerm.private_endpoint = azurerm.private_endpoint
  }
  source              = "git@github.com:hmcts/terraform-module-servicebus-namespace?ref=4.x"
  name                = "${var.product}-servicebus-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  env                 = var.env
  common_tags         = local.tags
  sku                 = var.sku
  zone_redundant      = (var.sku != "Premium" ? "false" : "true")
}

module "servicebus-queue-request" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=4.x"
  name                = "${var.product}-to-hmi-${var.env}"
  namespace_name      = module.servicebus-namespace.name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [module.servicebus-namespace]
}

module "servicebus-queue-response" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-queue?ref=4.x"
  name                = "${var.product}-from-hmi-${var.env}"
  namespace_name      = module.servicebus-namespace.name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [module.servicebus-namespace]
}

output "sb_primary_send_and_listen_connection_string" {
  value     = module.servicebus-namespace.primary_send_and_listen_connection_string
  sensitive = true
}

output "sb_primary_send_and_listen_shared_access_key" {
  value     = module.servicebus-namespace.primary_send_and_listen_shared_access_key
  sensitive = true
}

resource "azurerm_key_vault_secret" "servicebus_primary_connection_string" {
  name         = "hmc-servicebus-connection-string"
  value        = module.servicebus-namespace.primary_send_and_listen_connection_string
  key_vault_id = module.vault.key_vault_id
}

resource "azurerm_key_vault_secret" "servicebus_primary_shared_access_key" {
  name         = "hmc-servicebus-shared-access-key"
  value        = module.servicebus-namespace.primary_send_and_listen_shared_access_key
  key_vault_id = module.vault.key_vault_id
}

module "servicebus-topic" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-topic?ref=4.x"
  name                = "${var.product}-to-cft-${var.env}"
  namespace_name      = module.servicebus-namespace.name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [module.servicebus-namespace]
}

module "servicebus-subscription" {
  source              = "git@github.com:hmcts/terraform-module-servicebus-subscription?ref=4.x"
  name                = "${var.product}-subs-to-cft-${var.env}"
  namespace_name      = module.servicebus-namespace.name
  topic_name          = module.servicebus-topic.name
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [module.servicebus-topic]
}
