provider "vsphere" {
  vsphere_server = var.vsphere_server
  user           = var.vsphere_user
  password       = var.vsphere_password

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "Workload"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_storage_policy" "vm_storage_policy" {
  name = "vSAN Default Storage Policy"#""
}

data "vsphere_storage_policy" "hd_storage_policy" {
  name = "vSAN Default Storage Policy"#""
}

/*resource "vsphere_virtual_disk" "virtual_disk1" {
  size               = 40
  type               = "thin"
  vmdk_path          = "/vmfs/volumes/vsanDatastore/sz-vm-5/asz-vm-5_1.vmdk"
  create_directories = true
  datacenter         = data.vsphere_datacenter.dc.name
  datastore          = data.vsphere_datastore.datastore.name
}*/

resource "vsphere_virtual_machine" "vm" {
  name             = "asz-vm-5"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 1
  memory           = 1024
  guest_id         = "oracleLinux8_64Guest"#"centos64Guest"#"oracleLinux8_64Guest"#"centos64Guest"#"other3xLinux64Guest"
  #storage_policy_id = data.vsphere_storage_policy.vm_storage_policy.id
  #firmware = "efi"
  
  network_interface {
    network_id = data.vsphere_network.network.id
  }

cdrom {
    datastore_id = data.vsphere_datastore.datastore.id
    path         = "/vmfs/volumes/vsanDatastore/ISOs/OracleLinux-R8-U6-x86_64-dvd.iso"
  }
 
  disk {
    #label = "disk0"
    label = "disk0"
    size  = 16
    #path = "/vmfs/volumes/vsanDatastore/asz-vm-5/asz-vm-5.vmdk"#vsphere_virtual_disk.virtual_disk1.vmdk_path
    #enable_secure_boot = true
    thin_provisioned = true
    #unit_number = 0
  
  }
  
  /*disk {
    label = "disk1"
    attach = true
	  path = vsphere_virtual_disk.virtual_disk1.vmdk_path #"${vsphere_virtual_disk.disk_1.vmdk_path}"
    datastore_id     = data.vsphere_datastore.datastore.id
    #size  = 16
    #enable_secure_boot = true
    #thin_provisioned = true
    unit_number = 1
    #storage_policy_id = data.vsphere_storage_policy.hd_storage_policy.id
  }*/
}