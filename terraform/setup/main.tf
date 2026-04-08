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
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

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

# Add ssh key
resource "hcloud_ssh_key" "valheim" {
  for_each = var.ssh_keys
  name       = each.key
  public_key = each.value
}
