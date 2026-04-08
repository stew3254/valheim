# output "firewall" {
#   value = hcloud_firewall.valheim
# }

# output "ssh_keys" {
#   value = local.key_names
# }

output "all_ssh_keys" {
  value = data.hcloud_ssh_keys.all.ssh_keys
}

# output "new_ssh_keys" {
#   value = local.new_ssh_keys
# }
