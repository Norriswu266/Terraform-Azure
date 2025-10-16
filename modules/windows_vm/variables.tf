variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "vm_name" {
  type    = string
  default = "norrisTestVM"
}

variable "os_type" {
  description = "Operating system type: windows or linux"
  default     = "windows"
  type        = string
}

variable "admin_username" {
  type    = string
  default = "norris"
}

variable "admin_password" {
  type    = string
  default = "Microfusion@123"
}

variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = list(string)
  default     = ["172.33.0.0/24"]
}

variable "subnet_prefixes" {
  description = "List of subnet address prefixes"
  type        = list(string)
  default     = ["172.33.0.0/25"]
}

variable "subnet_names" {
  description = "List of subnet names"
  type        = list(string)
  default     = ["subnet1"]
}