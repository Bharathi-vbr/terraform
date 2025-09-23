#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 || echo "N/A")
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 || echo "N/A")

cat <<EOF > /var/www/html/index.html
<html>
  <head><title>EC2 Test Page</title></head>
  <body style="font-family:Arial,Helvetica,sans-serif;">
    <h1>Hello from my AWS EC2 server!</h1>
    <p><b>Private IP:</b> ${PRIVATE_IP}</p>
    <p><b>Public IP:</b> ${PUBLIC_IP}</p>
    <p><small>Deployed by Terraform user-data script</small></p>
  </body>
</html>
EOF
