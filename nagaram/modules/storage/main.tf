resource "aws_s3_bucket" "app_storage" {
    bucket = "${var.app_name}-app-storage-${var.environment}"

    tags = {
        Name = "${var.app_name}-app-storage-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_s3_bucket" "logs" {
    bucket = "${var.app_name}-logs-${var.environment}"

    tags = {
        Name = "${var.app_name}-logs-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_s3_bucket_versioning" "app_storage" {
    bucket = aws_s3_bucket.app_storage.id

    versioning_configuration {
        status = "Enabled"
    }
}