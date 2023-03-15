variable "usuario" {
  default = "pi5-grupo3"
}

variable "regiao" {
  default = "us-east-1"
}

variable "ami" {
  default = "ami-0557a15b87f6559cf"
}

variable "tipo_instancia" {
  default = "t2.micro"
}

variable "ip_internet" {
  default = "0.0.0.0/0"
}

variable "engine" {
  default = "mysql"
}

variable "engine_version" {
  default = "8.0.32"
}

variable "instance_identifier" {
  default = "pi5grupo03"
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "name" {
  default = "pi5grupo03"
}

variable "database_password" {}
