variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "project_name" {
  type = string
}

variable "key_name" {
  type        = string
  description = "Name of the SSH key pair to use for the VPN instance"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_eip" "vpn" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-vpn-eip"
  }
}

resource "aws_instance" "vpn" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro" # Cost effective
  subnet_id     = var.subnet_id

  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              
              # Pull OpenVPN container image
              docker pull kylemanna/openvpn
              
              # Create directory for VPN data
              mkdir -p /home/ec2-user/vpn-data
              chown ec2-user:ec2-user /home/ec2-user/vpn-data
              
              echo "OpenVPN Server prepared. SSH in and configure using kylemanna/openvpn container."
              EOF

  tags = {
    Name = "${var.project_name}-vpn-server"
  }
}

resource "aws_eip_association" "vpn" {
  instance_id   = aws_instance.vpn.id
  allocation_id = aws_eip.vpn.id
}

output "public_ip" {
  value = aws_eip.vpn.public_ip
}

output "instance_id" {
  value = aws_instance.vpn.id
}

