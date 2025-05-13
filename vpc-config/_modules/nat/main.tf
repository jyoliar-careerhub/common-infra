data "aws_subnet" "public" {
  id = var.public_subnet_id
}

data "aws_vpc" "this" {
  id = data.aws_subnet.public.vpc_id
}

resource "aws_security_group" "nat_instance_sg" {
  vpc_id      = data.aws_subnet.public.vpc_id
  name        = "${var.name}-sg"
  description = "Security group for NAT instance"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.this.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nat" {
  ami = "ami-00c2fe3c2e5f11a2b" //Amazon Linux 2023 AMI arm64

  instance_type = "t4g.micro"
  subnet_id     = var.public_subnet_id

  source_dest_check    = false
  iam_instance_profile = aws_iam_instance_profile.nat.name
  user_data            = <<EOT
#!/bin/bash

echo "*** Install iptables and start ***"
yum install iptables-services -y
systemctl enable iptables
systemctl start iptables

echo "*** Enable IP forwarding ***"
cat <<EOF | tee /etc/sysctl.d/custom-ip-forwarding.conf
net.ipv4.ip_forward = 1
EOF

sysctl -p /etc/sysctl.d/custom-ip-forwarding.conf

echo "*** Configure NAT ***"
/sbin/iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
/sbin/iptables -F FORWARD
service iptables save
  EOT

  vpc_security_group_ids = [aws_security_group.nat_instance_sg.id]
  tags = {
    Name = var.name
  }
}

resource "aws_route" "nat_gateway" {
  route_table_id         = var.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat.primary_network_interface_id
}

resource "aws_iam_instance_profile" "nat" {
  name = "${var.name}-instance-profile"

  role = aws_iam_role.nat.name
}

resource "aws_iam_role" "nat" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


#ssm 정책 추가
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.nat.name
}
