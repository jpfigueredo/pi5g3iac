resource "aws_db_instance" "pi5_grupo3_rds_database" {
  allocated_storage    = 50
  db_name              = var.name
  db_subnet_group_name = aws_db_subnet_group.pi5_grupo3_subnet_group.id
  engine               = var.engine
  engine_version       = var.engine_version
  publicly_accessible  = true
  identifier           = var.instance_identifier
  instance_class       = var.instance_class
  username             = "admin"
  password             = var.database_password
  skip_final_snapshot  = true
  availability_zone    = "${var.regiao}a"
  vpc_security_group_ids = [
    aws_security_group.SG_Mysql.id,
    lookup(var.ip_internet, "security_group_default_id")
  ]
}

resource "aws_db_subnet_group" "pi5_grupo3_subnet_group" {
  name = "database subnet group"
  subnet_ids = [
    lookup(var.ip_internet, "subnet_public_A_id"),
    lookup(var.ip_internet, "subnet_public_B_id"),
    lookup(var.ip_internet, "subnet_public_C_id")
  ]

  tags = {
    Name = "pi5 grupo3 database subnet group"
  }
}
