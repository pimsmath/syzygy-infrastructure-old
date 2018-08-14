# Determine the volume UUIDs, whether if existing ones were supplied
# or if new ones were created.
locals {
  vol_id_1 = "${length(var.existing_volumes) == 0 ?
    element(concat(openstack_blockstorage_volume_v2.homedir.*.id, list("")), 0) :
    element(concat(var.existing_volumes, list("")), 0)
  }"
}
resource "openstack_blockstorage_volume_v2" "homedir" {
  count = 1
  name  = "${format("%s-homedir-%02d", var.name, count.index+1)}"
  size  = "${var.vol_homedir_size}"
}

resource "openstack_compute_volume_attach_v2" "homedir_1" {
  instance_id = "${openstack_compute_instance_v2.hub.id}"
  volume_id   = "${openstack_blockstorage_volume_v2.homedir.0.id}"
}
