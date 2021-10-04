
locals {
  _default = {
    base_image_tag = "changeme"
    name_prefix    = "devopsoh"
  }
  _secrets = {
    bing_maps_key                             = "Ar6iuHZYgX1BrfJs6SRJaXWbpU_HKdoe7G-OO9b2kl3rWvcawYx235GGx5FPM76O"
    mssql_server_administrator_login          = "demousersa"
    mssql_server_administrator_login_password = "demo@pass123"
  }
}
