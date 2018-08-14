locals {
  shortname        = "example"
  name             = "example.syzygy.ca"
  public_key       = "${file("../../keys/id_rsa.pub")}"
  vol_homedir_size = 100 
  floatingip_pool  = "VLAN3337"
}

resource "openstack_compute_keypair_v2" "id_rsa" {
  name       = "id_cc_openstack_${local.shortname}"
  public_key = "${local.public_key}"
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = "${local.floatingip_pool}"
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  instance_id = "${module.hub.instance_uuid}"
  floating_ip = "${openstack_networking_floatingip_v2.fip.address}"
}

module "hub" {
  source           = "../modules/hub"
  name             = "${local.name}"
  key_name         = "${openstack_compute_keypair_v2.id_rsa.name}"
  vol_homedir_size = "${local.vol_homedir_size}"
}

resource "ansible_group" "hub" {
  inventory_group_name = "hub"
}

resource "ansible_group" "hub-dev" {
  inventory_group_name = "hub-dev"
}

resource "ansible_group" "jupyter" {
  inventory_group_name = "jupyter"
  children             = ["hub", "hub-dev"]
}

resource "ansible_host" "hub" {
  inventory_hostname = "${local.name}"
  groups             = ["hub", "hub-dev"]

  vars {
    ansible_user = "ptty2u"

    ansible_host            = "${local.name}"
    ansible_ssh_common_args = "-C -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
  }
}

output "floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip.address}"
}

