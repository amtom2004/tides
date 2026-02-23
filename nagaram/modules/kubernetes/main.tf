terraform {
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.0"
        }
    }
}

resource "kubernetes_namespace" "main" {
    metadata {
        name = "${var.app_name}-${var.environment}"
    }
}

resource "kubernetes_config_map" "app" {
    metadata {
        name = "${var.app_name}-config"
        namespace = kubernetes_namespace.main.metadata[0].name
    }

    data = {
        DB_HOST = "host.minikube.internal"
        DB_NAME = var.db_name
        DB_USER = var.db_username
        QUEUE_URL = var.queue_url
        S3_BUCKET = var.app_storage_bucket
        ENVIRONMENT = var.environment
        SQS_ENDPOINT = "http://host.minikube.internal:4566"
        S3_ENDPOINT = "http://host.minikube.internal:4566"
    }
}

resource "kubernetes_secret" "app" {
    metadata {
        name = "${var.app_name}-secret"
        namespace = kubernetes_namespace.main.metadata[0].name
    }

    data = {
        DB_PASSWORD = "nagaram123"
    }
}

resource "kubernetes_deployment" "app" {
    metadata {
        name = "${var.app_name}-deployment"
        namespace = kubernetes_namespace.main.metadata[0].name
        labels = {
            app = var.app_name
            environment = var.environment
        }
    }

    spec {
        replicas = var.app_replicas

        selector {
            match_labels = {
                app = var.app_name
            }
        }

        template {
            metadata {
                labels = {
                    app = var.app_name
                    environment = var.environment
                }
            }

            spec {
                container {
                    name = var.app_name
                    image = "nagaram-app:latest"
                    image_pull_policy = "Never"

                    port {
                        container_port = 5000
                    }

                    env_from {
                        config_map_ref {
                            name = kubernetes_config_map.app.metadata[0].name
                        }
                    }

                    env_from {
                        secret_ref {
                            name = kubernetes_secret.app.metadata[0].name
                        }
                    }
                }
            }
        }
    }
}

resource "kubernetes_service" "app" {
    metadata {
        name = "${var.app_name}-service"
        namespace = kubernetes_namespace.main.metadata[0].name
    }

    spec {
        selector = {
            app = var.app_name
        }

        port {
            port = 5000
            target_port = 5000
        }

        type = "NodePort"
    }
}