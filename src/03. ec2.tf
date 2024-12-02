resource "aws_instance" "bastion" {
  ami = data.aws_ssm_parameter.latest_ami.value
  subnet_id = aws_subnet.public_a.id
  instance_type = "t3.small"
  key_name = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  user_data = base64encode("${file("./src/bastion_userdata.sh")}")
  
  tags = {
    Name = "wsc-bastion-ec2"
  }

  depends_on = [
    aws_s3_bucket.app,
    aws_ecr_repository.ecr,
  ]
}

resource "aws_security_group" "bastion" {
  name = "wsc-EC2-SG"
  vpc_id = aws_vpc.main.id

  ingress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "2220"
    to_port = "2220"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "2220"
    to_port = "2220"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "80"
    to_port = "80"
  }
 
  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "443"
    to_port = "443"
  }

  egress {
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port = "4000"
    to_port = "4000"
  }

    tags = {
    Name = "wsc-EC2-SG"
  }
}
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  associate_with_private_ip = aws_instance.bastion.private_ip
}


resource "aws_iam_role" "bastion" {
  name = "wsc-bastion-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_iam_instance_profile" "bastion" {
  name = "wsc-profile-bastion"
  role = aws_iam_role.bastion.name
}