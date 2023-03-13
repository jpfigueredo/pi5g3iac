resource "aws_key_pair" "pi5_grupo3_key_pair" {
  key_name   = "${var.usuario}-pi5-grupo3-key-pair"
  public_key = file("pi5-grupo3-key-pair.pub")
}
