resource "openstack_blockstorage_volume_v2" "homedir" {
  count = 1
  name  = "${format("%s-homedir-%02d", var.name, count.index+1)}"
  size  = "${var.vol_homedir_size}"
}

resource "openstack_compute_volume_attach_v2" "homedir_1" {
  instance_id = "${openstack_compute_instance_v2.hub.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.homedir.0.id}"
}

