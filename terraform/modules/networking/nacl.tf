
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  ingress {
    rule_no    = 200
    protocol       = -1
    action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  egress {
    rule_no    = 200
    protocol       = -1
    action    = "allow"
    cidr_block     = "0.0.0.0/0"
    from_port = 0
    to_port = 0
  }

  subnet_ids = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]

  tags = {
    Name = "${var.project_name}_pub_acl"
  }
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.main.id

  ingress {
    rule_no    = 200
    protocol       = -1
    action    = "allow"
    cidr_block     = "173.0.0.0/16"
    from_port = 0
    to_port = 0
  }

  egress {
    rule_no    = 200
    protocol       = -1
    action    = "allow"
    cidr_block     = "173.0.0.0/16"
    from_port = 0
    to_port = 0
  }

  subnet_ids = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]

  tags = {
    Name = "${var.project_name}_priv_acl"
  }
}