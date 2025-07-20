provider "aws" {
  region = "ap-south-1"
}
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "my_instance" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = "t2.large"
  key_name      = "terra-key"
  security_groups = [aws_security_group.allow_all.name]

  root_block_device {
    volume_type = "gp2"
    volume_size = 30
  }

  tags = {
    Name = "UbuntuInstance"
  }
}