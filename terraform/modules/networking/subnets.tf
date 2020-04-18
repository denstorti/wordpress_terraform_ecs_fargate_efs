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