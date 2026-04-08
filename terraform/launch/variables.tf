# Provider Configuration
variable "hcloud_api_key" {
  type = string
  description = "Hetzner Cloud API Key"
  sensitive = true
}

# VM Configuration
variable "image" {
  type = string
  description = "The vm image"
  default = "ubuntu-24.04"
}

variable "server_type" {
  type = string
  description = "The vm flavor"
  default = "cpx11" # The smallest
}

variable "location" {
  type = string
  description = "The place the server will run"
  default = "ash" # Ashburn VA
}

# DNS Configuration
variable "dns_domain" {
  type = string
  description = "Domain name to retrieve zone info for"
  default = "rtstewart.dev"
}
