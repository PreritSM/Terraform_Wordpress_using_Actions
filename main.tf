terraform {
  backend "s3" {
    bucket = "terraform-statefile-pm29"
    key = "execution/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}

# Security Group to allow HTTP and SSH traffic
resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access (Restrict this to your IP for better security)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules (Required to download WordPress/Updates)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Set AWS region to US East 1 (N. Virginia)
}

# Local variables block for configuration values
locals {
    aws_key = "AWS_PM_KEYS"   # SSH key pair name for EC2 instance access
}

# EC2 instance resource definition
resource "aws_instance" "my_server" {
   ami           = data.aws_ami.amazonlinux.id  # Use the AMI ID from the data source
   instance_type = var.instance_type            # Use the instance type from variables
   key_name      = "${local.aws_key}"          # Specify the SSH key pair name
   user_data	 = file("wp_install.sh")
   vpc_security_group_ids = [aws_security_group.web_sg.id]

   # Add tags to the EC2 instance for identification
   tags = {
     Name = "my ec2"
   }                  
}


output "public_ip_addr" {
	value = aws_instance.my_server.public_ip
}




