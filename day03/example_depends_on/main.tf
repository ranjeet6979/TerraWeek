# --- Data sources: read existing info, don't create anything ---

# Latest Amazon Linux 2023 AMI in the chosen region.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Available AZs in the region.
data "aws_availability_zones" "available" {
  state = "available"
}


# --- Security group ---

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Allow HTTP inbound and all outbound"

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-web-sg"
  }
}

# --- Compute: EC2 that installs Nginx on boot ---
# We use `user_data` (a boot script) instead of SSH-based provisioners.
# That's the modern, reliable pattern: no key pair or SSH ingress needed, and
# it works even when the instance is replaced. (More on provisioners on Day 6.)

resource "aws_instance" "web" {

  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  availability_zone      = data.aws_availability_zones.available.names[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>Hello from TerraWeek 2026 🚀</h1>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_security_group.web]

  tags = {
    Name = "${var.name_prefix}"
  }
}
