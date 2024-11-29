provider "yandex" {
  zone = "ru-central1-b"
}

resource "yandex_compute_disk" "nginx-disk1" {
  name     = "nginx-disk1"
  type     = "network-hdd"
  size     = "15"
  image_id = "fd82odtq5h79jo7ffss3"
}

resource "yandex_compute_disk" "backend01-disk1" {
  name     = "backend01-disk1"
  type     = "network-hdd"
  size     = "15"
  image_id = "fd82odtq5h79jo7ffss3"
}

/* resource "yandex_compute_disk" "backend02-disk1" {
  name     = "backend02-disk1"
  type     = "network-hdd"
  size     = "15"
  image_id = "fd82odtq5h79jo7ffss3"
} */

resource "yandex_vpc_network" "network01" {
  name = "network01"
}

resource "yandex_vpc_subnet" "subnet01" {
  name           = "subnet01"
  network_id     = yandex_vpc_network.network01.id
  v4_cidr_blocks = ["10.16.0.0/24"]
}

resource "yandex_compute_instance" "nginx" {
  name = "nginx"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.nginx-disk1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "backend01" {
  name = "backend01"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.backend01-disk1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

/* resource "yandex_compute_instance" "backend02" {
  name = "backend02"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.backend02-disk1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet01.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
} */

resource "ansible_playbook" "nginx_provision" {
  playbook = "playbook.yml"

  name   = yandex_compute_instance.nginx.name
  groups = ["nginx"]

  limit = [yandex_compute_instance.nginx.name]

  extra_vars = {
    ansible_host                 = yandex_compute_instance.nginx.network_interface.0.nat_ip_address,
    ansible_user                 = "ubuntu",
    ansible_ssh_private_key_file = "~/.ssh/id_ed25519",
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no",
    nginx_external_ip            = yandex_compute_instance.nginx.network_interface.0.nat_ip_address,
    backend01_internal_ip        = yandex_compute_instance.backend01.network_interface.0.ip_address
  }

  replayable = true
  verbosity  = 3 # set the verbosity level of the debug output for this playbook
}

resource "ansible_playbook" "backend01_provision" {
  playbook = "playbook.yml"

  name   = yandex_compute_instance.backend01.name
  groups = ["backend"]

  limit = [yandex_compute_instance.backend01.name]

  extra_vars = {
    ansible_host                 = yandex_compute_instance.backend01.network_interface.0.nat_ip_address,
    ansible_user                 = "ubuntu",
    ansible_ssh_private_key_file = "~/.ssh/id_ed25519",
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
  }

  replayable = true
  verbosity  = 3 # set the verbosity level of the debug output for this playbook
}

/* resource "ansible_playbook" "backend02_provision" {
  playbook = "playbook.yml"

  name   = yandex_compute_instance.backend02.name
  groups = ["backend"]

  limit = [yandex_compute_instance.backend02.name]

  extra_vars = {
    ansible_host                 = yandex_compute_instance.backend02.network_interface.0.nat_ip_address,
    ansible_user                 = "ubuntu",
    ansible_ssh_private_key_file = "~/.ssh/id_ed25519",
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
  }

  replayable = true
  verbosity  = 3 # set the verbosity level of the debug output for this playbook
} */


output "internal_ip_address_nginx" {
  value = yandex_compute_instance.nginx.network_interface.0.ip_address
}

output "external_ip_address_nginx" {
  value = yandex_compute_instance.nginx.network_interface.0.nat_ip_address
}
