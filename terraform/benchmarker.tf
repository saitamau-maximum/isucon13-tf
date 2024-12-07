resource "sakuracloud_server" "isucon13-benchmarker" {
  name = var.benchmarker_name
  zone = var.zone

  core   = 8
  memory = 8
  disks  = [sakuracloud_disk.isucon13-benchmarker.id]

  network_interface {
    upstream = "shared"
  }

  network_interface {
    upstream = sakuracloud_switch.isucon13-switch.id
  }


  user_data = join("\n", [
    "#cloud-config",
    local.benchmarker-cloud-config,
    yamlencode({
      ssh_pwauth : false,
      ssh_authorized_keys : [
        file(var.public_key_path),
      ],
    }),
  ])
}

resource "sakuracloud_disk" "isucon13-benchmarker" {
  name = var.benchmarker_name
  zone = var.zone

  size              = 20
  source_archive_id = data.sakuracloud_archive.ubuntu.id
}

data "http" "benchmarker-cloud-config-source" {
  url = "https://raw.githubusercontent.com/matsuu/cloud-init-isucon/main/isucon13/isucon13.cfg"
}

locals {
  benchmarker-cloud-config = replace(data.http.benchmarker-cloud-config-source.body, "#cloud-config", "")
}

output "benchmarker_ip_address" {
  value = sakuracloud_server.isucon13-benchmarker.ip_address
}
