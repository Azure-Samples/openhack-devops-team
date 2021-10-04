############################################
## DATABASE                               ##
############################################

resource "null_resource" "db_schema" {
  depends_on = [
    azurerm_mssql_database.mssql_database
  ]
  provisioner "local-exec" {
    command = "sqlcmd -U ${local.mssql_server_administrator_login} -P ${local.mssql_server_administrator_login_password} -S ${azurerm_mssql_server.mssql_server.fully_qualified_domain_name} -d ${local.mssql_database_name} -i ../../support/datainit/MYDrivingDB.sql -e"
  }
}

resource "null_resource" "db_datainit" {
  depends_on = [
    null_resource.db_schema
  ]
  provisioner "local-exec" {
    command = "cd ../../support/datainit; bash ./sql_data_init.sh -s ${azurerm_mssql_server.mssql_server.fully_qualified_domain_name} -u ${local.mssql_server_administrator_login} -p ${local.mssql_server_administrator_login_password} -d ${local.mssql_database_name}; cd ../../iac/terraform"
  }
}

############################################
## DOCKER                                 ##
############################################

resource "null_resource" "docker_simulator" {
  depends_on = [
    azurerm_container_registry.container_registry
  ]
  provisioner "local-exec" {
    command = "az acr build --image devopsoh/simulator:latest --registry ${azurerm_container_registry.container_registry.login_server} --file ../../support/simulator/Dockerfile ../../support/simulator"
  }
}