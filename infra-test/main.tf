# Terraform
# Variáveis de ambiente
# export AWS_ACCESS_KEY_ID="sua_access_key"
# export AWS_SECRET_ACCESS_KEY="sua_secret_key"
# export AWS_DEFAULT_REGION="us-east-1"

# Criando a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc"
  }
}
# # Cria a VPC
# resource "aws_vpc" "main" {
#   cidr_block = var.vpc_cidr

#   tags = {
#     Name = "my-vpc"
#   }
# }



# Criando a Subnet Pública
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet"
  }
}
# # Cria a subnet pública
# resource "aws_subnet" "public" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = var.public_subnet_cidr
#   availability_zone = "${var.region}a"

#   tags = {
#     Name = "public-subnet"
#   }
# }



# Criando a Subnet Privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet"
  }
}
# # Cria a subnet privada
# resource "aws_subnet" "private" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = var.private_subnet_cidr
#   availability_zone = "${var.region}a"

#   tags = {
#     Name = "private-subnet"
#   }
# }



# Criando a Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
# # Cria o Internet Gateway
# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "igw"
#   }
# }



# Anexando a Internet Gateway à VPC
resource "aws_vpc_attachment" "vpc_igw_attachment" {
  vpc_id              = aws_vpc.vpc.id
  internet_gateway_id = aws_internet_gateway.igw.id
}




# Criando a Route Table Pública
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
}
# # Cria a tabela de rotas pública
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw.id
#   }

#   tags = {
#     Name = "public-route-table"
#   }
# }



# Adicionando a rota padrão para a Internet Gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associando a Route Table Pública à Subnet Pública
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
# # Associa a subnet pública à tabela de rotas pública
# resource "aws_route_table_association" "public" {
#   subnet_id      = aws_subnet.public.id
#   route_table_id = aws_route_table.public.id
# }



# Criando o Security Group para a Subnet Pública
resource "aws_security_group" "public_sg" {
  name   = "public-sg"
  vpc_id = aws_vpc.vpc.id

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
    from_port   = 443
    to_port     = 443
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
# # Cria o Security Group para a Subnet Pública
# resource "aws_security_group" "public" {
#   name_prefix = "public-sg-"

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "public-sg"
#   }
# }




resource "aws_security_group" "private" {
  name_prefix = "private-sg"
  vpc_id      = aws_vpc.network.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.network.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_eip" "nat" {}
# # Cria o Elastic IP para o NAT Gateway
# resource "aws_eip" "nat" {
#   vpc = true

#   tags = {
#     Name = "nat-eip"
#   }
# }



resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  depends_on = [
    aws_internet_gateway.gateway_attachment,
    aws_route_table.private,
  ]
}
# # Cria o NAT Gateway
# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public.id

#   tags = {
#     Name = "nat-gateway"
#   }
# }



resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
# # Associa a subnet privada à tabela de rotas privada
# resource "aws_route_table_association" "private" {
#   subnet_id      = aws_subnet.private.id
#   route_table_id = aws_route_table.private.id
# }

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

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
  depends_on             = [aws_nat_gateway.nat]
}




resource "aws_instance" "ansible" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.default.key_name
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [
    aws_security_group.public.id,
    aws_security_group.ssh_access.id,
  ]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y ansible
              EOF
}
# resource "aws_instance" "ansible" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
#   key_name      = aws_key_pair.default.key_name
#   subnet_id     = aws_subnet.private.id
#   vpc_security_group_ids = [
#     aws_security_group.public.id,
#     aws_security_group.ssh_access.id,
#   ]

#   user_data = <<-EOF
#               #!/bin/bash
#               apt-get update
#               apt-get install -y ansible
#               EOF
# }






resource "aws_instance" "docker_spring" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.default.key_name
  subnet_id     = aws_subnet.private.id
  vpc_security_group_ids = [
    aws_security_group.private.id,
    aws_security_group.ssh_access.id,
  ]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              docker run -p 8080:8080 -d my-java-spring-app
              EOF
}
# resource "aws_instance" "private" {
#   ami                    = var.ami
#   instance_type          = var.instance_type
#   key_name               = aws_key_pair.key.key_name
#   vpc_security_group_ids = [aws_security_group.private.id, aws_security_group.public.id]
#   subnet_id              = aws_subnet.private.id

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = file(var.private_key_path)
#     timeout     = "2m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update",
#       "sudo apt-get install -y docker.io",
#       "sudo docker run -d -p 8080:8080 ${var.spring_container_image}"
#     ]
#   }

#   tags = {
#     Name = "private-instance"
#   }
# }



resource "aws_instance" "docker_react" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.default.key_name
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.public.id,
    aws_security_group.ssh_access.id,
  ]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io
              docker run -p 3000:3000 -d my-react-app
              EOF
}
# resource "aws_instance" "public" {
#   ami                    = var.ami
#   instance_type          = var.instance_type
#   key_name               = aws_key_pair.key.key_name
#   vpc_security_group_ids = [aws_security_group.public.id]
#   subnet_id              = aws_subnet.public.id

#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = file(var.private_key_path)
#     timeout     = "2m"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt-get update",
#       "sudo apt-get install -y docker.io",
#       "sudo docker run -d -p 80:3000 ${var.react_container_image}"
#     ]
#   }

#   tags = {
#     Name = "public-instance"
#   }
# }

























# # Configura as credenciais da AWS
# provider "aws" {
#   access_key = var.aws_access_key
#   secret_key = var.aws_secret_key
#   region     = var.region
# }
