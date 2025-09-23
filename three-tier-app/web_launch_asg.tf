# web_launch_asg.tf
# Launch Template + Auto Scaling Group for the Web tier (public subnets).
# Free-tier friendly: t2.micro and single instance (min=1, desired=1, max=1).
# No IAM instance profile is attached per your architecture.

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Template for Web tier
resource "aws_launch_template" "web" {
  name_prefix   = "three-tier-web-"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = "t2.micro"

  # Attach the web security group; instances will have public IPs in public subnets
  network_interfaces {
    security_groups              = [aws_security_group.web_sg.id]
    associate_public_ip_address  = true
  }

  # Small root volume, delete on termination
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  # User data: install nginx and serve a simple static page
  user_data = base64encode(<<-EOF
              #!/bin/bash
              set -e
              yum update -y
              amazon-linux-extras install -y nginx1
              systemctl enable nginx
              cat > /usr/share/nginx/html/index.html <<'HTML'
              <html>
                <head><title>Three-tier Demo - Web</title></head>
                <body>
                  <h1>Three-tier Demo - Web Tier</h1>
                  <p>This is the web tier (static content served by nginx).</p>
                </body>
              </html>
              HTML
              systemctl start nginx
              EOF
  )
}

# Auto Scaling Group for Web tier
resource "aws_autoscaling_group" "web_asg" {
  name = "three-tier-web-asg"

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  # Place EC2 in the public subnets so ALB can reach them
  vpc_zone_identifier = module.vpc.public_subnet_ids

  # Register with ALB web target group created in alb.tf
  target_group_arns = [aws_lb_target_group.web_tg.arn]

  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  health_check_type    = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "three-tier-web"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "web"
    propagate_at_launch = true
  }
}
