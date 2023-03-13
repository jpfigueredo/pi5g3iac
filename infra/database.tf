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
    aws_security_group.sg_acesso_database.id
  ]
}

resource "aws_db_subnet_group" "pi5_grupo3_subnet_group" {
  name = "pi5grupo3 database subnet group"
  subnet_ids = [
    "subnet-05e70b7f28b65421f",
    "subnet-089f2373e8ae93e13",
    "subnet-0d8aca42219338177"
  ]
  tags = {
    Name = "pi5 grupo3 database subnet group"
  }

}
