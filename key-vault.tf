module "vault" {
  source                  = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  name                    = "${var.product}-${var.env}"
  product                 = var.product
  env                     = var.env
  tenant_id               = var.tenant_id
  object_id               = var.jenkins_AAD_objectId
  resource_group_name     = azurerm_resource_group.rg.name
  product_group_name      = "dcd_ccd"
  common_tags             = local.tags
  create_managed_identity = true
}

data "azurerm_key_vault" "s2s_vault" {
  name                = "s2s-${var.env}"
  resource_group_name = "rpe-service-auth-provider-${var.env}"
}

data "azurerm_key_vault_secret" "hmc_cft_hearing_service_s2s_key" {
  name         = "microservicekey-hmc-cft-hearing-service"
  key_vault_id = data.azurerm_key_vault.s2s_vault.id
}

resource "azurerm_key_vault_secret" "hmc_cft_hearing_service_s2s_secret" {
  name         = "hmc-cft-hearing-service-s2s-secret"
  value        = data.azurerm_key_vault_secret.hmc_cft_hearing_service_s2s_key.value
  key_vault_id = module.vault.key_vault_id
}

data "azurerm_key_vault_secret" "hmc_hmi_inbound_adapter_s2s_key" {
  name         = "microservicekey-hmc-hmi-inbound-adapter"
  key_vault_id = data.azurerm_key_vault.s2s_vault.id
}

resource "azurerm_key_vault_secret" "hmc_hmi_inbound_adapter_s2s_secret" {
  name         = "hmc-hmi-inbound-adapter-s2s-secret"
  value        = data.azurerm_key_vault_secret.hmc_hmi_inbound_adapter_s2s_key.value
  key_vault_id = module.vault.key_vault_id
}

data "azurerm_key_vault_secret" "api_gw_s2s_key" {
  name         = "microservicekey-api-gw"
  key_vault_id = data.azurerm_key_vault.s2s_vault.id
}

resource "azurerm_key_vault_secret" "api_gw_s2s_secret" {
  name         = "api-gateway-s2s-secret"
  value        = data.azurerm_key_vault_secret.api_gw_s2s_key.value
  key_vault_id = module.vault.key_vault_id
}

output "vaultName" {
  value = module.vault.key_vault_name
}

output "vaultUri" {
  value = module.vault.key_vault_uri
}
