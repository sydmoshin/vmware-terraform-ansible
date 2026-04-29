terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "~> 2.3"
    }
  }
}

provider "vsphere" {
  vsphere_server = var.vcenter_server
  user = var.vcenter_username
  password = var.vcenter_password
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "ds" {
  name = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name = var.cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  name = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id = data.vsphere_datastore.ds.id
  
  num_cpus = var.vm_cpus
  memory = var.vm_memory
  guest_id = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type
  
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }
  
  disk {
    label = "disk0"
    size = var.disk_size
    thin_provisioned = true
  }
  
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    
    customize {
      linux_options {
        host_name = var.vm_name
        domain = var.domain
      }
      
      network_interface {
        ipv4_address = ""
        ipv4_netmask = 0
      }
    }
  }
  
  connection {
    type = "ssh"
    user = "root"
    password = var.root_password
    host = self.default_ip_address
    timeout = "10m"
    agent = false
  }
  
  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "dnf update -y",
      "dnf install -y python3 python3-pip",
      "ln -sf /usr/bin/python3 /usr/bin/python"
    ]
  }
}

output "vm_ip" {
  value = vsphere_virtual_machine.vm.default_ip_address
}

output "vm_name" {
  value = vsphere_virtual_machine.vm.name
}
