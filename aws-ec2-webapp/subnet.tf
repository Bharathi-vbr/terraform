resource "aws_subnet" "public" {
  vpc_id = aws_vpc.test.id
  cidr_block = var.public_subnet_cidrs
  availability_zone = length(var.availability_zone)>0?var.availability_zone : null
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}