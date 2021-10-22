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
resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

resource "null_resource" "dependency_setter" {
  depends_on = [azurerm_application_insights.this]
}

locals {
  module_tags = {
    "ModuleVersion" = "3.1.0"
  }
}

resource "azurerm_application_insights" "this" {
  name                = "appi-${lower(var.name)}-${lower(var.project_name)}-${lower(var.organisation_name)}-${lower(var.environment_short)}"
  resource_group_name = var.resource_group_name
  location            = var.location
  application_type    = "web"

  tags                = merge(var.tags, local.module_tags)

  depends_on          = [
    null_resource.dependency_getter,
  ]

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}