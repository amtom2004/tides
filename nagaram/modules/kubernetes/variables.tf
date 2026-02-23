variable "app_name" {
    type = string
}

variable "environment" {
    type = string
}

variable "db_endpoint" {
    type = string
}

variable "db_name" {
    type = string
}

variable "db_username" {
    type = string
}

variable "queue_url" {
    type = string
}

variable "app_storage_bucket" {
    type = string
}

variable "app_replicas" {
    type = number
    default = 2
}