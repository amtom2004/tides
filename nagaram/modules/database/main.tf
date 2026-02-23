terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_container" "postgres" {
    name = "${var.app_name}-postgres-${var.environment}"
    image = "postgres:14"

    env = [
        "POSTGRES_DB=${var.db_name}",
        "POSTGRES_USER=${var.db_username}",
        "POSTGRES_PASSWORD=${var.db_password}"
    ]

    ports {
        internal = 5432
        external = 5432
    }

    restart = "always"
}