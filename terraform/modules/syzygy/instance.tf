resource "openstack_compute_instance_v2" "hub" {
  name = "${var.name}"

  image_id        = "${var.image_id}"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${var.key_name}"
  user_data       = "${local.cloudconfig}"

  network {
    name = "${var.network_name}"
  }
}

output "instance_uuid" {
  value = "${openstack_compute_instance_v2.hub.id}"
}
