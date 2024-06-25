terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"  
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


variable "private_key_path" {
  type        = string
  description = "Path to SSH private key (guava_api_key)"
  sensitive   = true
  default     = "/Users/queenoftheuniverse/.ssh/guava_api_key"  
}

# Security Group
resource "aws_security_group" "guava_sg" {  
  name        = "guava_security_group"
  description = "Allow SSH and HTTP"
  vpc_id      = "vpc-0361c8ad7fdd43ce5"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["104.62.54.111/32"]  
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}


resource "aws_instance" "guavainstance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  
  vpc_security_group_ids = [aws_security_group.guava_sg.id]

  subnet_id = "subnet-0a65eaaf8e17e841e" 
  
  tags = {
    Name = "guavainstance"
  }

 provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("/Users/queenoftheuniverse/.ssh/guava_api_key") 
      timeout     = "10m"
    }

    inline = [
      "sudo yum update -y", 
      "sudo amazon-linux-extras install epel -y",  
      "sudo yum install -y ansible", 
      "sudo chmod 600 /Users/queenoftheuniverse/.ssh/guava_api_key",
    ]
  }
}
