# Copyright 2020 Energinet DataHub A/S
#
# Licensed under the Apache License, Version 2.0 (the "License2");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
locals {
  module_tags = {
    "ModuleVersion" = "6.0.0"
    "ModuleId"      = "azure-eventhub-namespace"
  }
}

resource "azurerm_eventhub_namespace" "this" {
  name                = "evhns-${lower(var.name)}-${lower(var.project_name)}-${lower(var.environment_short)}-${lower(var.environment_instance)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity

  dynamic "network_rulesets" {
    for_each  = var.network_ruleset != null ? [var.network_ruleset] : []

    content {
      default_action                  = "Deny"
      trusted_service_access_enabled  = false
      ip_rule                         = []

      dynamic "virtual_network_rule" {
        for_each = network_rulesets.value.allowed_subnet_ids

        content {
          subnet_id                                       = virtual_network_rule.value
          ignore_missing_virtual_network_service_endpoint = false
        }
      }
    }
  }

  tags                = merge(var.tags, local.module_tags)

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }

  depends_on          = [
    var.private_endpoint_subnet_id
  ]
}

resource "random_string" "this" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_private_endpoint" "this" {
  name                = "pe-${lower(var.name)}${random_string.this.result}-${lower(var.project_name)}-${lower(var.environment_short)}-${lower(var.environment_instance)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                            = "psc-01"
    private_connection_resource_id  = azurerm_eventhub_namespace.this.id
    is_manual_connection            = false
    subresource_names               = ["namespace"]
  }

  tags                              = merge(var.tags, local.module_tags)

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
      private_dns_zone_group,
    ]
  }
}

# Create an A record pointing to the EventHub namespace private endpoint
resource "azurerm_private_dns_a_record" "this" {
  count               = var.private_dns_resource_group_name == null ? 0 : 1
  
  name                = azurerm_eventhub_namespace.this.name
  zone_name           = "privatelink.servicebus.windows.net"
  resource_group_name = var.private_dns_resource_group_name
  ttl                 = 3600
  records             = [
    azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
  ]

  depends_on          = [
    time_sleep.this,
  ]
}

# Waiting for the private endpoint to come online
resource "time_sleep" "this" {
  depends_on = [
    azurerm_private_endpoint.this
  ]
  create_duration = "120s" # 2 min should give us enough time for the Private endpoint to come online
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "diag-evhns-${lower(var.name)}-${lower(var.project_name)}-${lower(var.environment_short)}-${lower(var.environment_instance)}"
  target_resource_id         = azurerm_eventhub_namespace.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.log_retention_in_days
    }
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      log,
    ]
  }
}