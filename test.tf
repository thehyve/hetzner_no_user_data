variable "server_type" {
  type = string
  description = "defines resources for provisioned server"
  default = "cx31-ceph"
}
variable "ssh_key_private" {
  type = string
  description = "Ssh private key to use for connection to a server. Export TF_VAR_ssh_key_private environment variable to define a value."
}
variable "ssh_key" {
  type = string
  description = "An id of public key of ssh key-pairs that will be used for connection to a server. Export TF_VAR_ssh_key environment variable to define a value."
}
variable "remote_user" {
  type = string
  description = "A user being used for a connection to a server. By default is root, unless redefined with user-data (cloud-init)."
  default = "root"
}
variable "ipa00_server_name" {
  type = string
  description = "IPA00 server name"
  default = "ipa00"
}
variable "ipa00_location" {
  type = string
  description = "IPA00 server location"
  default = "nbg1"
}
variable "server_image" {
  type = string
  description = "An image being used for a server provisioning."
  default = "centos-7"
}

provider "hcloud" {
}

resource "hcloud_server" "ipa00" {
  name = "${var.ipa00_server_name}"
  server_type = "${var.server_type}"
  keep_disk = true
  backups = true
  image = "${var.server_image}"
  location = "${var.ipa00_location}"
  ssh_keys = [
    "${var.ssh_key}",
  ]
  user_data = "${templatefile("cloud_config.yml", { fixed_ip = "${hcloud_floating_ip.ipa00.ip_address}"})}"
}

resource "hcloud_floating_ip" "ipa00" {
  type = "ipv4"
  home_location = "${var.ipa00_location}"
}

resource "hcloud_floating_ip_assignment" "ipa00" {
  floating_ip_id = "${hcloud_floating_ip.ipa00.id}"
  server_id = "${hcloud_server.ipa00.id}"
}
