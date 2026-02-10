resource "aws_internet_gateway" "wordpress_igw" {
  vpc_id = var.vpc_id
}

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wordpress_igw.id
  }
}
