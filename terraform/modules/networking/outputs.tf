output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]
}

output "public_subnets" {
  value = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]
}
