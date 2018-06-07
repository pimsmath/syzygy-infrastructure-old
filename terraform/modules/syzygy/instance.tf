resource "openstack_compute_instance_v2" "hub" {
  name = "${var.name}"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${var.key_name}"
  security_groups = ["${openstack_networking_secgroup_v2.syzygy_tf.name}"]
  user_data       = "${local.cloudconfig}"
 
  block_device {
    uuid                  = "${var.image_id}"
    source_type           = "image"
    volume_size           = 30
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "${var.network_name}"
  }
}

output "instance_uuid" {
  value = "${openstack_compute_instance_v2.hub.id}"
}
