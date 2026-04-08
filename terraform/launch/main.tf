terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.60"
    }
  }
  # backend "pg" {
  #   schema_name = "labs"
  # }
}

provider "hcloud" {
  token = var.hcloud_api_key
}

data "terraform_remote_state" "setup" {
  backend = "local"
  config = {
    path = "../setup/terraform.tfstate"
  }
}

# data "terraform_remote_state" "save" {
#   backend = "local"
#   config = {
#     path = "../save/terraform.tfstate"
#   }
# }

# Create a server for the student
resource "hcloud_server" "lab" {
  name = "valheim"
  image = var.image
  server_type = var.server_type
  location = var.location
  # user_data = data.cloudinit_config.lab.rendered

  ssh_keys = data.terraform_remote_state.setup.outputs.ssh_keys
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  firewall_ids = [data.terraform_remote_state.setup.outputs.firewall.id]

  lifecycle {
    ignore_changes = [
      labels,
      ssh_keys,
      user_data
    ]
  }
}

# Acquire the zone information
data hcloud_zone "domain" {
  name = trimsuffix(var.dns_domain, ".")
}

# Create a DNS record for the resource
resource "hcloud_zone_rrset" "valheim" {
  zone    = var.dns_domain
  name = "new-valheim"
  ttl = 60
  type    = "A"
  records = [{ value = hcloud_server.lab.ipv4_address }]
}

# Create the corresponding reverse DNS record
# resource "hcloud_rdns" "lab" {
#   server_id = hcloud_server.lab.id
#   ip_address = hcloud_server.lab.ipv4_address
#   dns_ptr = local.lab_domain
# }
