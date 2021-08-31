provider "bigip" {
  address = var.bigip_ip
  username = var.bigip_username
  password = var.bigip_password
  port = var.bigip_port
}


data "template_file" "init" {
  template = file("as3_simple.tpl")
  vars = {
    VIP_ADDRESS = var.vip_address
  }
}

resource "bigip_as3" "config" {
  as3_json = data.template_file.init.rendered
}
