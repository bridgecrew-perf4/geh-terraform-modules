# Azure Service Bus Queue

- [Resources Created](#resources-created)
- [Prerequisites](#prerequisites)
- [Arguments and defaults](#arguments-and-defaults)
- [Usage](#usage)
- [Outputs](#outputs)

## Resources Created

<<<<<<< HEAD
**Notice**: [Partitioning is not support when using Premium Messaging](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-premium-messaging#partitioned-queues-and-topics)
=======
This module creates the following resources:
>>>>>>> a47859ad862856e0be46cb59862f6ccdd06514c7

This module creates the following resources:

- [Azure Service Bus Queue](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue)

## Prerequisites

<<<<<<< HEAD
- Terraform version 1.1.2+
- AzureRM provider version 2.91.0+
=======
- Terraform version 1.1.7+
- AzureRM provider version 2.97.0+
>>>>>>> a47859ad862856e0be46cb59862f6ccdd06514c7

## Arguments and defaults

See [variables.tf](./variables.tf)

## Usage

```ruby
module "service_bus_queue_example" {
  source              = "git::https://github.com/Energinet-DataHub/geh-terraform-modules.git//azure/service_bus-queue?ref=6.0.0"
  name                = "example-name"
  namespace_id        = "/subscriptions/<subscription id>/resourceGroups/<resource group>/providers/Microsoft.ServiceBus/namespaces/example-namespace-name"
}
```

## Outputs

See [outputs.tf](./outputs.tf)
