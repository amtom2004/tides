module "prod_cluster" {
    source = "./modules/kind-cluster"
    cluster_name = "prod-cluster"
    container_port = 80
    host_port = 8081
}

module "dev_cluster" {
    source = "./modules/kind-cluster"
    cluster_name = "dev-cluster"
    container_port = 80
    host_port = 8082
}

module "staging_cluster" {
    source = "./modules/kind-cluster"
    cluster_name = "staging-cluster"
    container_port = 80
    host_port = 8083
}

output "dev_cluster_endpoint" {
    value = module.dev_cluster.endpoint
}