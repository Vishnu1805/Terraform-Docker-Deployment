# Get latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# Security Group
resource "aws_security_group" "task_sg" {
  name        = "task-manager-sg"
  description = "Allow SSH and App"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "task_manager" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.task_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              apt-get update -y

              # Install Docker
              apt-get install -y docker.io git

              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu

              # Clone your repo
              cd /home/ubuntu
              git clone https://github.com/Vishnu1805/TASK-MANAGER.git
              cd TASK-MANAGER

              # Build Docker image
              docker build -t task-manager .

              # Run container
              docker run -d -p 3000:80 --name task-container task-manager
              EOF
  
  tags = {
    Name = "task-manager-terraform"
  }
}
