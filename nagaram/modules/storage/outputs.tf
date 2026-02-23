output "app_storage_bucket" {
    value = aws_s3_bucket.app_storage.bucket
}

output "logs_bucket" {
    value = aws_s3_bucket.logs.bucket
}

output "app_storage_bucket_arn" {
    value = aws_s3_bucket.app_storage.arn
}