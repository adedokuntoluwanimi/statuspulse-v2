terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6.0"
}

provider "aws" {
  region = var.region
}

# Security Group
resource "aws_security_group" "statuspulse_sg" {
  name_prefix = "statuspulse-sg"
  description = "Allow SSH, HTTP, Jenkins, and SonarQube access"

  # Ingress rules
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "statuspulse_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.statuspulse_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt update -y
              apt install -y docker.io openjdk-17-jdk curl unzip apt-transport-https ca-certificates gnupg

              systemctl enable docker
              systemctl start docker

              # Install kubectl
              curl -fsSL https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
              chmod +x /usr/local/bin/kubectl

              # Run Jenkins container
              docker run -d -p 8080:8080 -p 50000:50000 --name jenkins \
                -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts

              # Run SonarQube container
              docker run -d -p 9000:9000 --name sonarqube sonarqube:lts-community
              EOF

  tags = {
    Name = "statuspulse-jenkins-sonar"
  }
}
