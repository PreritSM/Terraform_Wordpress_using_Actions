resource "aws_instance" "wordpress_ec2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.ec2_sg_id]
  key_name               = var.key_name

  user_data = templatefile("${path.root}/wp_rds_install.sh", {
    db_name     = "wordpressdb"
    db_user     = var.db_username
    db_pass     = var.db_password
    db_endpoint = var.rds_endpoint
  })
}
