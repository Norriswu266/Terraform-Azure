#  output "ssh_private_key" {
#   value     = tls_private_key.ssh_key.private_key_pem
#   sensitive = true
# }

# output "public_ip" {
#   value = var.os_type == "windows" ? module.windows_vm[0].public_ip : module.linux_vm[0].public_ip
#   description = "Public IP of the VM"
# }