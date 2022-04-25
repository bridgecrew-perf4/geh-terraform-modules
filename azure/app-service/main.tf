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
    "ModuleVersion" = "5.8.0",
    "ModuleId"      = "azure-app-service"
  }
}

resource "azurerm_app_service" "this" {
  name                        = "app-${lower(var.name)}-${lower(var.project_name)}-${lower(var.environment_short)}-${lower(var.environment_instance)}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  app_service_plan_id         = var.app_service_plan_id
  https_only                  = true

  app_settings                = merge({
    APPINSIGHTS_INSTRUMENTATIONKEY = var.application_insights_instrumentation_key
  }, var.app_settings)

  identity {
    type = "SystemAssigned"
  }

  site_config {
    dotnet_framework_version = var.dotnet_framework_version
    always_on = var.always_on
    health_check_path = var.health_check_path
    cors {
      allowed_origins = ["*"]
    }
  }

  dynamic "connection_string" {
    for_each  = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  tags      = merge(var.tags, local.module_tags)

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_monitor_metric_alert" "health_check_alert" {
  count               = var.health_check_alert_action_group_id == null ? 0 : 1

  name                = "hca-${azurerm_app_service.this.name}"
  resource_group_name = var.resource_group_name

  enabled             = var.health_check_alert_enabled
  severity            = 1
  scopes              = [azurerm_app_service.this.id]
  description         = "Action will be triggered when health check fails."

  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace  = "Microsoft.Web/Sites"
    metric_name       = "HealthCheckStatus"
    operator          = "LessThan"
    aggregation       = "Average"
    threshold         = 100
  }

  action {
    action_group_id   = var.health_check_alert_action_group_id
  }

  tags                = merge(var.tags, local.module_tags)

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}