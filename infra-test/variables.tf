# Define as variáveis
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "private_subnet_cidr" {}

# Configura as credenciais da AWS
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

# Cria a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "my-vpc"
  }
}

# Cria a subnet pública
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "public-subnet"
  }
}

# Cria a subnet privada
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.region}a"

  tags = {
    Name = "private-subnet"
  }
}

# Cria o Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

# Cria a tabela de rotas pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associa a subnet pública à tabela de rotas pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Cria o NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "nat-gateway"
  }
}

# Cria o Elastic IP para o NAT Gateway
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat-eip"
  }
}

# Cria a tabela de rotas privada
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associa a subnet privada à tabela de rotas privada
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Cria o Security Group para a Subnet Pública
resource "aws_security_group" "public" {
  name_prefix = "public-sg-"

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

  tags = {
    Name = "public-sg"
  }
}

resource "aws_instance" "public" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.public.id]
  subnet_id              = aws_subnet.public.id

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo docker run -d -p 80:3000 ${var.react_container_image}"
    ]
  }

  tags = {
    Name = "public-instance"
  }
}

resource "aws_instance" "private" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.key.key_name
  vpc_security_group_ids = [aws_security_group.private.id, aws_security_group.public.id]
  subnet_id              = aws_subnet.private.id

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y docker.io",
      "sudo docker run -d -p 8080:8080 ${var.spring_container_image}"
    ]
  }

  tags = {
    Name = "private-instance"
  }
}

