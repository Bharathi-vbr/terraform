# Terraform AWS Infrastructure

Provision a scalable AWS infrastructure using Terraform. This setup includes a VPC, public subnets, EC2 instances with user data scripts, and an S3 bucket.

---

## 📌 Project Overview

This project uses [Terraform](https://www.terraform.io/) to automate the deployment of:

- A **VPC** with three public subnets  
- Two **EC2 Instances** (with user data initialization)  
- An **S3 Bucket** for storage  
- An **Internet Gateway** with appropriate routing  

> Ideal for learning infrastructure-as-code (IaC) or bootstrapping small cloud environments.

---

## 📁 Directory Structure

terraform-aws-infrastructure/
├── main.tf # Infrastructure resources
├── provider.tf # AWS provider configuration
├── variables.tf # Input variable definitions
├── userdata1.sh # Script for EC2 instance 1
├── userdata2.sh # Script for EC2 instance 2
└── README.md # Project documentation

yaml
Copy
Edit

---

## 🧱 Architecture Diagram

![Architecture](images/aws-infra-diagram.png)  
<!-- Replace this path with your actual image path or remove if not used -->

---

## 🚀 Getting Started

### ✅ Prerequisites

- Terraform >= 1.0
- AWS CLI installed & configured (`aws configure`)
- An active AWS account with IAM permissions

---

## 📦 Setup Instructions

📦 Setup Instructions
🔹 Step 1: Clone the Repository
bash
Copy
Edit
git clone https://github.com/Bharathi-vbr/terraform-aws-infrastructure.git
cd terraform-aws-infrastructure

### 🔹 Step 2: Initialize Terraform
terraform init

### 🔹 Step 3: Review the Plan
terraform plan

### 🔹 Step 4: Apply Infrastructure
terraform apply

Confirm with yes when prompted

### 🔹 Step 5: Destroy Infrastructure (Optional)

terraform destroy


### 🔐 Security Notes
Do NOT commit .tfvars or AWS credentials to version control.

Use IAM roles or environment variables for authentication.

### 🧾 User Data Scripts
userdata1.sh and userdata2.sh initialize EC2 instances (e.g., installing packages, setting up services).

### 📄 License
Licensed under the MIT License. See the LICENSE file for details.

Created with ❤️ using Terraform and AWS

✅ Instructions:
Do not copy this into a code block or within triple backticks in your README.md.

Paste this directly as plain Markdown text into the GitHub README.md editor.

