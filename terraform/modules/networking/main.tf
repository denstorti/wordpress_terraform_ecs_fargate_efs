
resource "aws_vpc" "main" {
  cidr_block = "173.0.0.0/16"
	tags = {
    Name = "${var.project_name}_vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}_igw"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}_private_rt"
  }
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}_public_rt"
  }
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_ecr_repository" "aws_3m" {
  name                 = "aws_3m"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-aws_3m"
  }
}

resource "aws_ecr_repository" "terraform_3m" {
  name                 = "terraform_3m"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-terraform_3m"
  }
}

resource "aws_ecr_repository" "wordpress" {
  name                 = "wordpress"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-wordpress"
  }
}