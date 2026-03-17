resource "aws_key_pair" "auth_key" {

  key_name   = "${var.project_name}-${var.project_environment}"
  public_key = file("mykey.pub")
  tags = {
    Name = "${var.project_name}-${var.project_environment}"
  }
}

resource "aws_security_group" "webserver" {

  name        = "${var.project_name}-${var.project_environment}"
  description = "Allow all Inbound and OutBound"

  ingress {

    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {

    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {

    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.project_environment}-webserver"
  }
}

resource "aws_instance" "webserver" {

  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.auth_key.key_name
  vpc_security_group_ids = [aws_security_group.webserver.id]
  user_data              = file("setup.sh")
  tags = {
    "Name" = "${var.project_name}-${var.project_environment}-webserver"
  }
}

resource "aws_eip" "webserver" {
  domain = "vpc"
}

resource "aws_eip_association" "webserver" {
  instance_id   = aws_instance.webserver.id
  allocation_id = aws_eip.webserver.id
}

resource "aws_route53_record" "webserver" {

  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.hostname
  type    = "A"
  ttl     = 5
  records = [aws_eip.webserver.public_ip]
}
