terraform {
    required_providers {
        multipass = {
            source = "larstobi/multipass"
            version = "~> 1.4"
        }
    }
}

provider multipass {}

resource "local_file" "cloud_init" {
    filename = "${path.module}/cloud-init.yaml"
    content = templatefile("${path.module}/cloud-init.tpl", {
        app_base64 = filebase64("${path.module}/app.py")
    })
}

resource "multipass_instance" "penguin-vm" {
    name = "penguin-vm"
    cpus = 1
    memory = "1GiB"
    disk = "5GiB"
    image = "22.04"

    cloudinit_file = local_file.cloud_init.filename

    depends_on = [local_file.cloud_init]
}