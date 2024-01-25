resource "aws_vpc" "default" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_security_group" "default" {
  name = "default"
  description = "default VPC security group"
  vpc_id = aws_vpc.default.id
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    protocol = "-1"
    to_port = 0
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "anyway db"
    from_port = 9002
    to_port = 9002
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "terraform state db"
    from_port = 9001
    to_port = 9001
    protocol = "tcp"
  }
  ingress {
    from_port = 0
    to_port = 0
    self = true
    protocol = "-1"
  }
}

resource "aws_subnet" "default" {
  vpc_id = aws_vpc.default.id
  availability_zone = "eu-central-1b"
  cidr_block = "172.31.32.0/20"
  map_public_ip_on_launch = true
}

resource "aws_eip" "main_docker" {}

output "main_docker_ip" {
  value = aws_eip.main_docker.public_ip
}

resource "aws_eip_association" "main_docker" {
  allocation_id = aws_eip.main_docker.id
  instance_id = aws_instance.main_docker.id
}

resource "aws_instance" "main_docker" {
  ami = "ami-0faab6bdbac9486fb"
  availability_zone = "eu-central-1b"
  instance_type = "m6a.large"
  vpc_security_group_ids = [aws_security_group.default.id]
  subnet_id = aws_subnet.default.id
  tags = {
    Name = "main-docker"
  }
}

resource "aws_ebs_volume" "main_docker" {
  availability_zone = "eu-central-1b"
  size = 500
  tags = {
      Name = "main-docker"
  }
  type = "gp3"
}

resource "aws_ebs_volume" "main_docker_root" {
  availability_zone = "eu-central-1b"
  size = 100
  type = "gp3"
}

resource "aws_volume_attachment" "main_docker_root" {
  device_name = "/dev/sda1"
  instance_id = aws_instance.main_docker.id
  volume_id = aws_ebs_volume.main_docker_root.id
}

resource "aws_volume_attachment" "main_docker" {
  device_name = "/dev/sdf"
  instance_id = aws_instance.main_docker.id
  volume_id = aws_ebs_volume.main_docker.id
}

resource "aws_dlm_lifecycle_policy" "main_docker_backup" {
  description = "main docker backup"
  execution_role_arn = "arn:aws:iam::896911843692:role/service-role/AWSDataLifecycleManagerDefaultRole"
  policy_details {
    resource_types = ["INSTANCE"]
    target_tags = {
      Name = "main-docker"
    }
    parameters {
      exclude_boot_volume = false
    }
    schedule {
      name = "Monthly"
      variable_tags = {
        "instance-id" = "$(instance-id)"
        "timestamp" = "$(timestamp)"
      }
      create_rule {
        cron_expression = "cron(00 23 ? * 6#1 *)"  # 1st Friday of every month at 23:00 UTC
      }
      retain_rule {
        count = 1
      }
    }
  }
}
