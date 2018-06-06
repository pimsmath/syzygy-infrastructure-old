resource "ansible_group" "jupyter" {
  inventory_group_name = "jupyter"
}

resource "ansible_group" "syzygy" {
  inventory_group_name = "syzygy"
  children             = ["jupyter"]
}

