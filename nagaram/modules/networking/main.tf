resource "aws_vpc" "main" {
    
    cidr_block = var.vpc_cidr

    tags = {
        Name = "${var.app_name}-vpc-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_subnet" "public" {

    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr

    tags = {
        Name = "${var.app_name}-public-subnet-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_subnet" "private" {
    
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr

    tags = {
        Name = "${var.app_name}-private-subnet-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_subnet" "database" {

    vpc_id = aws_vpc.main.id
    cidr_block = var.db_subnet_cidr

    tags = {
        Name = "${var.app_name}-db-subnet-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_internet_gateway" "main" {
    
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.app_name}-igw-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_route_table" "public" {
    
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "${var.app_name}-public-rt-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "app" {
    
    name = "${var.app_name}-app-sg-${var.environment}"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.app_name}-app-sg-${var.environment}"
        Environment = var.environment
    }
}

resource "aws_security_group" "database" {
    name = "${var.app_name}-db-sg-${var.environment}"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.app.id]
    }

    tags = {
        Name = "${var.app_name}-db-sg-${var.environment}"
        Environment = var.environment
    }
}