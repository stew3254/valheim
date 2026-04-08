variable "hcloud_api_key" {
  type = string
  description = "Hetzner Cloud API Key"
  sensitive = true
}

variable "ssh_keys" {
  type = map(string)
  description = "A list of ssh keys to load into the instance"
}
