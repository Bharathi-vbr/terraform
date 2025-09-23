# Read user data from file
data "local_file" "userdata" {
  filename = var.user_data_file
}

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = length(var.key_name) > 0 ? var.key_name : null
  user_data              = data.local_file.userdata.content
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-ec2"
  }
}
