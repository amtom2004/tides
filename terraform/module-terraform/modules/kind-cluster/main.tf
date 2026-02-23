resource "kind_cluster" "cluster" {
    name = var.cluster_name
    node_image = "kindest/node:v1.27.1"
    wait_for_ready = true

    kind_config {
        kind = "Cluster"
        api_version = "kind.x-k8s.io/v1alpha4"

        node {
            role = "control-plane"
            extra_port_mappings {
                container_port = var.container_port
                host_port = var.host_port
            }
        }

        node {
            role = "worker"
        }
    }
}