

variable "os_type" {
  description = "Operating system type: windows or linux"
  type        = string
  validation {
    condition     = contains(["windows", "linux"], var.os_type)
    error_message = "os_type must be either 'windows' or 'linux'."
  }
}

# variable "enable_vpn" {
#   description = "是否啟用 VPN 模組 (true/false)"
#   type        = bool
# }


variable "location" {
  description = "The Azure region to deploy resources in"
  type        = string
  default     = "East Asia"
}

variable "resource_group_name"{
  type    = string
  default = "terraform-resources"
}

variable "public_ip_id" {
  description = "Public IP 資源 ID"
  default     = "20.22.11.22"
  type        = string
}

variable "gateway_subnet_id" {
  description = "Gateway Subnet 的 ID"
  default     = "20.22.11.33"
  type        = string
}