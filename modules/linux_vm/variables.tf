variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "vm_name" {
  type    = string
  default = "my-vm-linux"
}

variable "os_type" {
  description = "Operating system type: windows or linux"
  default     = "linux"
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


