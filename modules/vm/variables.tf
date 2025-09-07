variable "nic_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}
variable "public_ip_id" {}
variable "vm_name" {}
variable "vm_size" {}
variable "admin_username" {}
variable "admin_password" {}
variable "lb_backend_pool_id" {
  description = "Backend pool ID to associate with NIC"
  type        = string
  default     = null
}


