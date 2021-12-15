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
variable name {
  type        = string
  description = "(Required) Specifies the name of the SQL table dataset. Changing this forces a new resource to be created."
}

variable resource_group_name {
  type        = string
  description = "(Required) The name of the resource group in which to create the SQL table dataset. Changing this forces a new resource."
}

variable data_factory_name {
  type        = string
  description = "(Required) The Data Factory name in which to associate the SQL table dataset with. Changing this forces a new resource."
}

variable linked_service_name {
  type        = string
  description = "(Required) The Data Factory Linked Service name in which to associate the Dataset with."
}

variable table_name {
  type        = string
  description = "(Optional) The table name of the Data Factory Dataset SQL Server Table."
}

variable dependencies {
  type        = list
  description = "A mapping of dependencies which this module depends on."
  default     = []
}