# app_launch_asg.tf
# Launch Template + Auto Scaling Group for the App tier (private subnets).
# Assumes a single data.aws_ami.amazon_linux2 is defined globally (e.g. in ami.tf).
# Runs a minimal Python backend (http.server) without pip, so NAT is not required.

resource "aws_launch_template" "app" {
  name_prefix   = "three-tier-app-"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = "t2.micro"

  # Attach the app security group; instances will be in private subnets (no public IPs)
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  # Root volume
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 8
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  # User data script: Python backend
  user_data = base64encode(<<EOF
#!/bin/bash
set -e

APP_DIR=/opt/three-tier-app
mkdir -p "${APP_DIR}"

cat > "${APP_DIR}/app.py" <<'PY'
#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import json

class Handler(BaseHTTPRequestHandler):
    def _send_json(self, d, code=200):
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps(d).encode('utf-8'))

    def do_GET(self):
        if self.path == '/health':
            self._send_json({"status":"ok"})
        elif self.path == '/api/greet':
            self._send_json({"message":"Hello from App tier (Python builtin server)!"})
        else:
            self._send_json({"error":"not found"}, code=404)

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), Handler)
    print("Starting app on 0.0.0.0:8080")
    server.serve_forever()
PY

yum update -y
yum install -y python3

cat > /etc/systemd/system/three-tier-app.service <<'UNIT'
[Unit]
Description=Three Tier App (Python builtin)
After=network.target

[Service]
User=root
WorkingDirectory=/opt/three-tier-app
ExecStart=/usr/bin/python3 /opt/three-tier-app/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable three-tier-app.service
systemctl start three-tier-app.service
EOF
  )
}

resource "aws_autoscaling_group" "app_asg" {
  name = "three-tier-app-asg"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Place instances in private subnets
  vpc_zone_identifier = module.vpc.private_subnet_ids

  # Register with ALB app target group
  target_group_arns = [aws_lb_target_group.app_tg.arn]

  min_size             = 1
  max_size             = 1
  desired_capacity     = 1

  health_check_type         = "ELB"
  health_check_grace_period = 120

  tag {
    key                 = "Name"
    value               = "three-tier-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "app"
    propagate_at_launch = true
  }
}
