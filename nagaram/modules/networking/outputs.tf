output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_subnet_id" {
    value = aws_subnet.public.id
}

output "private_subnet_id" {
    value = aws_subnet.private.id
}

output "db_subnet_id" {
    value = aws_subnet.database.id
}

output "app_security_group_id" {
    value = aws_security_group.app.id
}

output "db_security_group_id" {
    value = aws_security_group.database.id
}