output "vpc_id" {
    description = "VPC_ID"
    value = module.networking.vpc_id
}

output "app_storage_bucket" {
    description = "S3 Bucket for app storage"
    value = module.storage.app_storage_bucket
}

output "logs_bucket" {
    description = "S3 Bucket for logs"
    value = module.storage.logs_bucket
}

output "queue_url" {
    description = "SQS Queue URL"
    value = module.queue.queue_url
}

output "deadletter_queue_url" {
    description = "SQS Deadletter Queue URL"
    value = module.queue.deadletter_queue_url
}

output "db_endpoint" {
    description = "Database Endpoint"
    value = module.database.db_endpoint
}

output "db_name" {
    description = "Database name"
    value = module.database.db_name
}

output "kubernetes_namespace" {
    description = "Kubernetes Namespace"
    value = module.kubernetes.namespace
}

output "kubernetes_service" {
    description = "Kubernetes Service Name"
    value = module.kubernetes.service_name
}
