resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.test.id
    tags = { Name = "${var.project_name}-igw"}
  
}