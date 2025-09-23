# AWS EC2 User Data Web Server with ALB, Route53 & ACM

This project demonstrates how to deploy a **public web application on AWS** using Terraform.  
It provisions a simple EC2 instance (with a user-data script that installs Apache and displays its IPs), an Application Load Balancer (ALB), Route 53 DNS records, and an ACM-managed SSL/TLS certificate for HTTPS.

---

## 📐 Architecture Overview

![Architecture Diagram](diagrams/architecture.png)

**Flow:**
1. User requests a URL (e.g., `https://demo.example.com`).
2. **Route 53** resolves the domain to the Application Load Balancer (ALB).
3. **AWS Certificate Manager (ACM)** provides the SSL/TLS certificate for HTTPS.
4. **ALB** terminates HTTPS and forwards HTTP traffic to the target group.
5. Target group routes traffic to **EC2** instance(s) running in a **public subnet** of the **VPC**.
6. **EC2** serves a simple HTML page with its private and public IP addresses.

---

## ⚙️ Components & Why They Are Needed

### 1. **VPC (Virtual Private Cloud)**
- **Why:** Provides network isolation for resources.
- **Need:** Defines the CIDR block (`10.0.0.0/16`) and acts as a container for all subnets, route tables, and gateways.

### 2. **Subnet (Public Subnet)**
- **Why:** Breaks down the VPC into smaller addressable ranges.
- **Need:** Public subnet ensures EC2 and ALB have direct access to the internet via an Internet Gateway.

### 3. **Internet Gateway (IGW) + Route Table**
- **Why:** Provides internet connectivity to resources inside the VPC.
- **Need:** Required for public EC2 instances and the ALB to receive requests from the outside world.

### 4. **Security Groups**
- **Why:** Firewall rules for controlling inbound/outbound traffic.
- **Need:**
  - **ALB SG:** Allows inbound 80/443 from the internet.
  - **EC2 SG:** Allows inbound traffic only from the ALB SG and SSH from your IP.

### 5. **EC2 Instance**
- **Why:** The compute resource hosting our test web server.
- **Need:** Runs a user-data script to install Apache and create an `index.html` that prints the private & public IP of the instance.

### 6. **User Data Script**
- **Why:** Bootstraps the server automatically on launch.
- **Need:** Ensures that as soon as EC2 is created, it serves a simple HTML page without manual configuration.

### 7. **Application Load Balancer (ALB)**
- **Why:** Provides scalability, HTTPS termination, and health checks.
- **Need:** Terminates TLS, distributes traffic, and forwards only healthy traffic to EC2 targets.

### 8. **Target Group**
- **Why:** Defines where ALB forwards requests.
- **Need:** Registers EC2 instances and performs health checks (path `/`).

### 9. **AWS Certificate Manager (ACM)**
- **Why:** Manages SSL/TLS certificates for HTTPS.
- **Need:** Provides a free, auto-renewed certificate validated via Route 53 DNS.

### 10. **Route 53**
- **Why:** Managed DNS service for resolving domains.
- **Need:** Creates an A-record (ALIAS) mapping the domain to the ALB DNS name.

---

## 📋 Prerequisites

- **AWS Account** with sufficient permissions to create VPC, EC2, ALB, Route53, ACM.
- **Terraform** v1.5+ installed → [Install guide](https://developer.hashicorp.com/terraform/downloads).
- **AWS CLI** installed and configured → run:
  ```bash
  aws configure
  ```
 ## ▶️ Deployment Steps

## Clone repo
```bash
git clone https://github.com/Bharathi-vbr/terraform.aws-ec2-webapp.git
cd aws-ec2-webapp
  ```

## Update variables in terraform.tfvars:
```bash
aws_region         = "us-east-1"
ami_id             = "ami-0c55b159cbfafe1f0"
key_name           = "my-keypair"
hosted_zone_id     = "Z123456789ABC"
domain_name        = "demo.example.com"
```

## Initialize Terraform

```bash
terraform init
```

## Preview plan

```bash
terraform plan -var-file="terraform.tfvars"
```

## Apply changes
```bash
terraform apply -var-file="terraform.tfvars"
```

## Test
```bash
Open browser → https://demo.example.com
```

## You should see:

Hello from my AWS EC2 server!
Private IP: 10.0.1.x
Public IP: 3.x.x.x

## 🧹 Cleanup

To destroy everything created:

terraform destroy -var-file="terraform.tfvars"

## 🔒 Security Notes

Restrict SSH access in security_groups.tf to your IP only.

Never commit terraform.tfvars if it contains sensitive data.

Use IAM least-privilege for Terraform execution.

In production, deploy EC2s in private subnets and use an Auto Scaling Group.

## 🚀 Next Steps / Improvements

Add Auto Scaling Group for EC2.

Use private subnets with a NAT gateway for better security.

Add CloudFront for CDN + WAF for security filtering.

Replace EC2 with ECS/EKS for containerized workloads.
