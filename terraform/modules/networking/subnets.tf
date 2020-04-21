data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private-subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "173.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.project_name}-private-sub1"
  }
}

resource "aws_subnet" "private-subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "173.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.project_name}-private-sub2"
  }
}

resource "aws_subnet" "public-subnet1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "173.0.128.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-sub1"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "173.0.129.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-sub2"
  }
}

resource "aws_ssm_parameter" "vpc_id" {
  name        = "/${var.environment}/network/vpc_id"
  description = "VPC ID"
  type  = "String"
  value = aws_vpc.main.id
}

resource "aws_ssm_parameter" "private_subnets_id" {
  name        = "/${var.environment}/network/subnets/private"
  description = "Private subnet IDs"
  type  = "StringList"
  value = "${aws_subnet.private-subnet1.id},${aws_subnet.private-subnet2.id}"
}

resource "aws_ssm_parameter" "public_subnets_id" {
  name        = "/${var.environment}/network/subnets/public"
  description = "Public subnet IDs"
  type  = "StringList"
  value = "${aws_subnet.public-subnet1.id},${aws_subnet.public-subnet2.id}"
}
