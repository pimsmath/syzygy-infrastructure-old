locals {
  name             = "dal.syzygy.ca"
  image_id         = "5088c906-1636-4319-9dcb-76ab92257731" # CentOS 7
  flavor_name      = "c2-7.5gb-31"
  network_name     = "jupyterhub_network"
  public_key       = "${file("~/.ssh/id_cc_openstack.pub")}"
  vol_homedir_size = 100 
  floatingip_pool  = "VLAN3337"
}

resource "openstack_compute_keypair_v2" "id_cc_openstack_tf" {
  name       = "id_cc_openstack-tf"
  public_key = "${local.public_key}"
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = "${local.floatingip_pool}"
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  instance_id = "${module.syzygy.instance_uuid}"
  floating_ip = "${openstack_networking_floatingip_v2.fip.address}"
}

module "syzygy" {
  source           = "../modules/syzygy"
  name             = "${local.name}"
  image_id         = "${local.image_id}"
  flavor_name      = "${local.flavor_name}"
  key_name         = "${openstack_compute_keypair_v2.id_cc_openstack_tf.name}"
  network_name     = "${local.network_name}"
  vol_homedir_size = "${local.vol_homedir_size}"
}

resource "ansible_group" "syzygy" {
  inventory_group_name = "dal"
}

resource "ansible_group" "jupyter" {
  inventory_group_name = "jupyter"
  children             = ["syzygy"]
}

resource "ansible_host" "dal" {
  inventory_hostname = "${local.name}"
  groups             = ["syzygy"]

  vars {
    ansible_user = "ptty2u"
    ansible_host            = "${local.name}"
    ansible_ssh_common_args = "-C -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  }
}

output "floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip.address}"
}
