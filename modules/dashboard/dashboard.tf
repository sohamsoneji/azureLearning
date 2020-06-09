resource "azurerm_monitor_diagnostic_setting" "azure_terraform_ex1_mds" {
  name               = var.mds_name
  target_resource_id = var.vmid
  storage_account_id = var.storageaccid

  log {
    category = "AuditEvent"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_action_group" "azure_terraform_ex1_mag" {
  name                = "CriticalAlertsAction"
  resource_group_name = var.rg_name
  short_name          = "p0action"

email_receiver {
    name          = "sendtoadmin"
    email_address = var.email_id
  }
}

resource "azurerm_monitor_metric_alert" "azure_terraform_ex1_mma" {
  name                = var.mma_name
  resource_group_name = azurerm_monitor_action_group.azure_terraform_ex1_mag.resource_group_name
  scopes              = [var.vmid, var.storageaccid]
  description         = "Action will be triggered when the CPU usage is greater than 85%."

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.azure_terraform_ex1_mag.id
  }
}
