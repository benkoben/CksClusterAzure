resource "azurerm_resource_group" "cksprep" {
  name     = "rg-cksprep-${local.shortlocations[var.location]}-${var.env}-01"
  location = var.location
  tags     = var.tags
}

module "masterlinuxserver" {
  source                           = "Azure/compute/azurerm"
  resource_group_name              = azurerm_resource_group.cksprep.name
  data_disk_size_gb                = 64
  location = var.location
  data_sa_type                     = "Premium_LRS"
  delete_data_disks_on_termination = true
  vm_os_publisher                  = "Canonical"
  vm_os_offer                      = "0001-com-ubuntu-server-focal"
  vm_os_sku                        = "20_04-lts"
  vm_hostname                      = "master01"
  nb_instances                     = 1
  vm_size                          = "Standard_B4ms"
  remote_port                      = "22"
  public_ip_dns                    = ["kooijman-cks-master01"] 
  vnet_subnet_id                   = module.network.vnet_subnets[0]
  enable_ssh_key                   = true
  ssh_key = var.ssh_pub_key_path

  tags       = var.tags
  depends_on = [azurerm_resource_group.cksprep]
}

module "workerlinuxserver" {
  source                           = "Azure/compute/azurerm"
  location = var.location
  resource_group_name              = azurerm_resource_group.cksprep.name
  data_disk_size_gb                = 64
  data_sa_type                     = "Premium_LRS"
  delete_data_disks_on_termination = true
  vm_os_publisher                  = "Canonical"
  vm_os_offer                      = "0001-com-ubuntu-server-focal"
  vm_os_sku                        = "20_04-lts"
  vm_size                          = "Standard_B4ms"
  vm_hostname                      = "worker01"
  nb_instances                     = 1
  remote_port                      = "22"
  public_ip_dns                    = ["kooijman-cks-worker01"]
  vnet_subnet_id                   = module.network.vnet_subnets[0]
  enable_ssh_key                   = true
  ssh_key = var.ssh_pub_key_path

  #   connection {
  #     type        = "ssh"
  #     user        = "root"
  #     private_key = file(substr(var.ssh_pub_key_path, 0, -4))
  #     host        = self.public_ip
  #   }
  # 
  #   provisioner "remote-exec" {
  #     inline = [
  #       "bash <(curl -s https://raw.githubusercontent.com/killer-sh/cks-course-environment/master/cluster-setup/latest/install_worker.sh)"
  #     ]
  #   }

  tags       = var.tags
  depends_on = [azurerm_resource_group.cksprep]
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.cksprep.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["default"]

  tags       = var.tags
  depends_on = [azurerm_resource_group.cksprep]
}

output "master_vm_public_name" {
  value = module.masterlinuxserver.public_ip_dns_name
}

output "worker_vm_public_name" {
  value = module.workerlinuxserver.public_ip_dns_name
}
