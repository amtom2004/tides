output "queue_url" {
    value = aws_sqs_queue.main.url
}

output "queue_arn" {
    value = aws_sqs_queue.main.arn
}

output "deadletter_queue_url" {
    value = aws_sqs_queue.deadletter.url
}