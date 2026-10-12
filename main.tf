data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "jenkins" {
  name   = "jenkins-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "jenkins" {
  name = "jenkins-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.jenkins.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins.name
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins.name
  user_data              = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = { Name = "jenkins-server" }
}

resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"
}