resource "aws_sqs_queue" "main" {
    name = "${var.app_name}-queue-${var.environment}"
    delay_seconds = 0
    max_message_size = 262144
    message_retention_seconds = 86400
    receive_wait_time_seconds = 10

    tags = {
        Name = "${var.app_name}-queue-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_sqs_queue" "deadletter" {
    name = "${var.app_name}-queue-deadletter-${var.environment}"

    tags = { 
        Name = "${var.app_name}-queue-deadletter-${var.environment}"
        Environment = var.environment
    }
}