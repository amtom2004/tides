locals {
    workspace_config = {
        default = {
            container_port = 80
            host_port = 8080
        }
        dev = {
            container_port = 80
            host_port = 8081
        }
        staging = {
            container_port = 80
            host_port = 8082
        }
        prod = {
            container_port = 80
            host_port = 8083
        }
    }

    config = local.workspace_config[terraform.workspace]
}

resource "kind_cluster" "cluster" {
    name = "${terraform.workspace}-cluster"
    node_image = "kindest/node:v1.27.1"
    wait_for_ready = true

    kind_config {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"

        node {
            role = "control-plane"
            extra_port_mappings {
                container_port = local.config.container_port
                host_port = local.config.host_port
            }
        }

        node {
            role = "worker"
        }
    }
}