terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2      = "http://localhost:4566"
    s3       = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    rds      = "http://localhost:4566"
    sqs      = "http://localhost:4566"
    ecr      = "http://localhost:4566"
    iam      = "http://localhost:4566"
    sts      = "http://localhost:4566"
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "minikube"
}

module "networking" {
  source      = "./modules/networking"
  app_name    = var.app_name
  environment = var.environment
}

module "storage" {
  source      = "./modules/storage"
  app_name    = var.app_name
  environment = var.environment
}

module "queue" {
  source      = "./modules/queue"
  app_name    = var.app_name
  environment = var.environment
}

module "database" {
  source      = "./modules/database"
  app_name    = var.app_name
  environment = var.environment
  db_subnet_id         = module.networking.db_subnet_id
  db_security_group_id = module.networking.db_security_group_id
}

module "kubernetes" {
  source = "./modules/kubernetes"
  app_name = var.app_name
  environment = var.environment
  db_endpoint = module.database.db_endpoint
  db_name = module.database.db_name
  db_username = module.database.db_username
  queue_url = module.queue.queue_url
  app_storage_bucket = module.storage.app_storage_bucket
  app_replicas = var.app_replicas
}