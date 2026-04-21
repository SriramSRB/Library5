provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "library5_vpc" {
    cidr_block = "10.0.0.0/16"
    tags       = { Name = "library5-vpc" }
}

resource "aws_subnet" "library5_subnet" {
    vpc_id                  = aws_vpc.library5_vp.id
    cidr_block              = "10.0.0.0/21"
    map_public_ip_on_launch = true
    availability_zone       = "ap-south-1a"
    tags                    = { Name = "library5-subnet" }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.library5_vp.id
}

resource "aws_route_table" "library5_rt" {
    vpc_id = aws_vpc.library5_vp.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "library5_association" {
    subnet_id      = aws_subnet.library5_subnet.id
    route_table_id = aws_route_table.library5_rt.id
}

resource "aws_security_group" "library5_sg" {
    vpc_id = aws_vpc.library5_vp.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 30080
        to_port     = 30080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "library5_key" {
    key_name   = "library5-key"
    public_key = file(f:/file/devops/library5/library5-key.pub) 
}

resource "aws_instance" "library5_server" {
    ami                    = "ami-05d2d839d4f73aafb"
    instance_type          = "m71-flex.large"
    subnet_id              = aws_subnet.library5_subnet.id
    vpc_security_group_ids = [aws_security_group.library5_sg.id]
    key_name               = aws_key_pair.library5_key.key_name

    root_block_device {
        volume_size = 16
        volume_type = "gp3"

        tags        = { Nmae = "library5-server" }
    }
}