variable "environment" {
    type = string
    default = "dev"
}

variable "region" {
    type = string
    default = "us-east-1"
}

variable "app_name" {
    type = string
    default = "nagaram"
}

variable "app_replicas" {
    type = number
    default = 2
}