variable "image_id" {
  default = "5088c906-1636-4319-9dcb-76ab92257731" # CentOS 7
}

variable "flavor_name" {
  default = "c2-7.5gb-31"
}

variable "key_name" {}

variable "network_name" {
  default = "jupyterhub_network"
}

variable "name" {
  default = ""
}

variable "existing_volumes" {
  type = "list"

  default = []
}

variable "vol_homedir_size" {
  default = 10
}

locals {
  cloudconfig = <<EOF
    #cloud-config
    preserve_hostname: true
    runcmd:
      - sed -i '/\/dev\/vdb/d' /etc/fstab
      - swaplabel -L swap0 /dev/sdb
      - echo "LABEL=swap0 none  swap  defaults  0  0" >> /etc/fstab
    system_info:
      default_user:
        name: ptty2u
  EOF
}
