resource "aws_db_subnet_group" "wp_db_group" {
  name       = "wordpress_db_subnet_group"
  subnet_ids = [var.public_subnet_id, var.private_subnet_id]
}

resource "aws_db_instance" "wordpress_db" {
  identifier           = "wordpress-db"
  allocated_storage    = 20
  instance_class       = "db.t3.micro"
  engine               = "mysql"
  db_name              = "wordpressdb"
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name = aws_db_subnet_group.wp_db_group.name
  skip_final_snapshot  = true
}
