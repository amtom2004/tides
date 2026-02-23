variable "cluster_name" {
    type = string
    default = "test_cluster"
    description = "name of the kind cluster"
}

variable "container_port" {
    type = number
    default = 80
    description = "Port of the app running in the container"
}

variable "host_port" {
    type = number
    default = 8080
    description = "Port of the host system accessed by app"
}