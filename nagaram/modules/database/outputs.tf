output "db_endpoint" {
    value = "host.minikube.internal"
}

output "db_name" {
    value = var.db_name
}

output "db_username" {
    value = var.db_username
}

output "db_port" {
    value = 5432
}