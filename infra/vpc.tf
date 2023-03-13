resource "aws_vpc" "pi5_grupo3_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "pi5_grupo3_VPC"
  }
}

resource "aws_subnet" "pi5_grupo3_public_subnet" {
  vpc_id     = aws_vpc.pi5_grupo3_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "pi5_grupo3_private_subnet" {
  vpc_id     = aws_vpc.pi5_grupo3_vpc.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_internet_gateway" "pi5_grupo3_internet_gateway" {
  vpc_id = aws_vpc.pi5_grupo3_vpc.id
}

resource "aws_route_table" "pi5_grupo3_public_route_table" {
  vpc_id = aws_vpc.pi5_grupo3_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pi5_grupo3_internet_gateway.id
  }
}


resource "aws_route_table_association" "pi5_grupo3_public_route_table_association" {
  subnet_id      = aws_subnet.pi5_grupo3_public_subnet.id
  route_table_id = aws_route_table.pi5_grupo3_public_route_table.id
}
