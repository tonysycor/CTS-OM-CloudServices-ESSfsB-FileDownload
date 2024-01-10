data "azurerm_storage_account" "existing" {
  name                = var.storage_account # Replace with your existing storage account name

  resource_group_name = var.resource_group_name   # Replace with your resource group name

 
}

data "azurerm_storage_container" "existing" {

  name                   = var.storage_container_name # Replace with your existing blob name
  storage_account_name   = data.azurerm_storage_account.existing.name
  
}
data "azurerm_storage_blob" "existing" {
  
  name                   = var.policy_definition_file  # Replace with your existing blob name
  storage_account_name   = data.azurerm_storage_account.existing.name
  storage_container_name = data.azurerm_storage_container.existing.name  # Replace with your container name
}
/*resource "azurerm_storage_blob" "existing" {
  name                   = "basicpolicies.csv"  # Replace with your existing blob name
  storage_account_name   = data.azurerm_storage_account.existing.name
  type ="Block"
  storage_container_name = "basicpolicy"   # Replace with your container name
}*/
data "azurerm_storage_account_sas" "existing" {
  connection_string =  data.azurerm_storage_account.existing.primary_connection_string
  https_only        = true
  signed_version = "2022-11-02"
  start             = timestamp()
  expiry            = timeadd(timestamp(), "1h")


  resource_types {
    service = false
    container = true
    object = true
  }
  services {
    blob = true
    queue = true
    table = true
    file = true
    }
    permissions {
        read = true
        write = true
        delete = true
        list = true
        add = true
        create = true
        update = true
        process = true
        tag = true
        filter = true
    }

 
  
}
data "http" "policy_download" {
  
  url = "${data.azurerm_storage_blob.existing.url}${data.azurerm_storage_account_sas.existing.sas}"
  request_headers = {
    Accept = "application/csv"
  }
}
resource "local_file" "downloaded_blob" {
  content  = data.http.policy_download.body
  filename = var.policy_definition_file
}
output "sas"{
  value=data.azurerm_storage_account_sas.existing.sas
  sensitive = true
}
  
  

