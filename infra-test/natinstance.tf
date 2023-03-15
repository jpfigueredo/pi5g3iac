# Criando a instância EC2 para atuar como NAT Instance
resource "aws_instance" "nat" {
  ami                         = "ami-0c55b159cbfafe1f0"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "my_keypair"
  subnet_id                   = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.nat.id
  ]

  tags = {
    Name = "NAT Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo 1 > /proc/sys/net/ipv4/ip_forward
              sysctl -w net.ipv4.conf.all.send_redirects=0
              sysctl -w net.ipv4.conf.eth0.send_redirects=0
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              EOF
}

# Criando o security group para a instância NAT
resource "aws_security_group" "nat" {
  name_prefix = "nat"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "NAT Security Group"
  }
}

# Criando a rota para a internet via NAT Instance
resource "aws_route" "nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_instance.nat.public_ip
}

# Associando a rota do NAT Instance com a subnet privada
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
