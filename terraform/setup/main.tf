terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.60"
    }
  }
  # backend "pg" {}
}

provider "hcloud" {
  token = var.hcloud_api_key
}

# Create a new firewall
resource "hcloud_firewall" "valheim" {
  name = "valheim"

  # Allow ping
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Allow ssh for debugging
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Open ports for valheim
  dynamic "rule" {
    for_each = toset(["2456", "2457", "2458"])
    content {
      direction = "in"
      protocol  = "udp"
      port      = rule.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}

# Grab all existing ssh keys to see if we need to filter any out
data "hcloud_ssh_keys" "all" {}

locals {
  # Set of public keys already registered in hcloud
  existing_public_keys = toset([
    for key in data.hcloud_ssh_keys.all.ssh_keys : trimspace(key.public_key)
  ])

  # Only keep var.ssh_keys entries whose public key isn't already registered
  new_ssh_keys = {
    for name, pubkey in var.ssh_keys :
    name => pubkey
    if !contains(local.existing_public_keys, trimspace(pubkey))
  }
}

resource "hcloud_ssh_key" "valheim" {
  for_each   = local.new_ssh_keys
  name       = each.key
  public_key = each.value
  labels     = { app = "valheim" }
}
