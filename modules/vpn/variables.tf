variable "name" {
  description = "VPN Gateway 名稱"
  type        = string
  default     = "my-vpn-gateway"
}

variable "location" {
  description = "部署區域"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group 名稱"
  type        = string
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

