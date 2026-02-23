variable "app_name" {
    type = string
}

variable "environment" {
    type = string
}

variable "db_name" {
    type = string
    default = "nagaramdb"
}

variable "db_username" {
    type = string
    default = "admin"
}

variable "db_password" {
    type = string
    sensitive = true
    default = "nagaram123"
}

variable "db_subnet_id" {
    type = string
}

variable "db_security_group_id" {
    type = string
}