# Terraform AWS 3-Tier Architecture

This repository provisions a **highly available 3-tier application architecture** on AWS using Terraform.

---

## 🏗️ Architecture

<img width="2242" height="1242" alt="image" src="https://github.com/user-attachments/assets/1d4742ab-a36e-4439-b2f0-8d5535d1f8ea" />


---

## ⚙️ Versions

- **Terraform**: >= 1.0  
- **AWS Provider**: >= 5.0  

---

## 🔑 Prerequisites

- AWS CLI configured with valid IAM credentials  
- A Route53-managed domain (e.g., `example.com`)  
- IAM permissions to provision **VPC, EC2, ALB, RDS, WAF, CloudFront, ACM, Route53**

---

## 🚀 Deployment

```bash
terraform init
terraform plan
terraform apply
```
## 📡 Outputs
```bash
- CloudFront Distribution URL
- ALB DNS names (Web & App tier)
- Route53 Alias Records
- Aurora DB Endpoint
- Secrets Manager ARN for DB credentials
```
## 🛑 Cleanup
```bash
terraform destroy
```
