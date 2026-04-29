variable "vcenter_server" {
  default = "vcenter80-hp800g2.corp.mohtel.com"
}

variable "vcenter_username" {
  default = "administrator@vsphere.local"
}

variable "vcenter_password" {
  sensitive = true
  default = "Wajed2moh#"
}

variable "datacenter" {
  default = "Datacenter"
}

variable "datastore" {
  default = "Datastore-hpz620-4TB"
}

variable "cluster_name" {
  default = "Cluster"
}

variable "network_name" {
  default = "VM Network"
}

variable "template_name" {
  default = "alma9-template"
}

variable "vm_name" {
  description = "Name of the VM to create"
  type = string
}

variable "vm_cpus" {
  default = 2
}

variable "vm_memory" {
  default = 4096
}

variable "disk_size" {
  default = 40
}

variable "domain" {
  default = "corp.mohtel.com"
}

variable "root_password" {
  description = "Root password for the VM"
  type = string
  sensitive = true
  default = "wajed2moh"
}
