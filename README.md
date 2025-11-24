# 🚀 Teachy Infrastructure Solution

This repository contains the complete infrastructure solution for the Teachy Infrastructure Code Challenge. It implements a secure, serverless architecture on AWS using **Terragrunt**, Docker, and GitHub Actions.


---

## Why Terragrunt?

We chose **Terragrunt** over vanilla Terraform to adhere to the **DRY (Don't Repeat Yourself)** principle and ensure scalable infrastructure management.

1.  **DRY Backend Configuration**: Terragrunt allows us to define the S3 state backend configuration **once** in the root `terragrunt.hcl` and inherit it across all modules. In vanilla Terraform, this block must be copied to every single module, increasing maintenance burden and risk of errors.
2.  **Dependency Management**: Terragrunt explicitly handles dependencies (e.g., *ALB depends on VPC*). The `run-all apply` command automatically builds the dependency graph and executes deployment in the correct parallel order.
3.  **Environment Separation**: It enforces a clear separation between configuration (`live/`) and logic (`modules/`), making it trivial to spin up new environments (staging, prod) by simply creating a new folder structure without duplicating Terraform code.

> [Gruntwork Documentation](https://terragrunt.gruntwork.io/)

---

## How to Run the Project

### Prerequisites
- **AWS CLI** configured (`aws configure`)
- **Terraform** (v1.0+) & **Terragrunt** installed
- **Docker** running locally

### 1. Build & Push Docker Images
The Lambdas run as container images. You must push them to your AWS ECR before deploying.

#### Windows (PowerShell)
```powershell
# 1. Login to ECR
$accountId = aws sts get-caller-identity --query "Account" --output text
$registry = "$accountId.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $registry

# 2. Build & Push Public Lambda
docker build -t teachy-public-lambda ./lambdas/public-api/
docker tag teachy-public-lambda:latest "$registry/teachy-public-lambda:latest"
docker push "$registry/teachy-public-lambda:latest"

# 3. Build & Push Private Lambda
docker build -t teachy-private-lambda ./lambdas/private-api/
docker tag teachy-private-lambda:latest "$registry/teachy-private-lambda:latest"
docker push "$registry/teachy-private-lambda:latest"
```

#### Linux / Mac (Bash)
```bash
# 1. Login to ECR
export ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
export REGISTRY="$ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $REGISTRY

# 2. Build & Push Public Lambda
docker build -t teachy-public-lambda ./lambdas/public-api/
docker tag teachy-public-lambda:latest "$REGISTRY/teachy-public-lambda:latest"
docker push "$REGISTRY/teachy-public-lambda:latest"

# 3. Build & Push Private Lambda
docker build -t teachy-private-lambda ./lambdas/private-api/
docker tag teachy-private-lambda:latest "$REGISTRY/teachy-private-lambda:latest"
docker push "$REGISTRY/teachy-private-lambda:latest"
```

### 2. Deploy Infrastructure
Run the deployment using Terragrunt.

#### Windows (PowerShell)
```powershell
# 1. Set Environment Variables
$env:TF_VAR_public_lambda_image = "$registry/teachy-public-lambda:latest"
$env:TF_VAR_private_lambda_image = "$registry/teachy-private-lambda:latest"
$env:TF_VAR_ssh_key_name = "teachy-vpn-key" # Ensure this Key Pair exists in AWS

# 2. Apply
cd infrastructure/live/dev
terragrunt run-all apply
```

#### Linux / Mac (Bash)
```bash
# 1. Set Environment Variables
export TF_VAR_public_lambda_image="$REGISTRY/teachy-public-lambda:latest"
export TF_VAR_private_lambda_image="$REGISTRY/teachy-private-lambda:latest"
export TF_VAR_ssh_key_name="teachy-vpn-key"

# 2. Apply
cd infrastructure/live/dev
terragrunt run-all apply
```

### 3. Destroy Infrastructure


```bash
terragrunt run-all destroy
```

---

## Evidence of Completion

https://youtu.be/_YHG5eaf6UU

---

## 📂 Project Structure

```
.
├── infrastructure/
│   ├── modules/            # Reusable Terraform Modules
│   │   ├── vpc/            # Network configuration
│   │   ├── security/       # Security Groups
│   │   ├── lambda/         # Lambda Function definition
│   │   ├── alb/            # Load Balancer & Listeners
│   │   └── vpn/            # OpenVPN Server
│   └── live/               # Terragrunt Configuration
│       ├── terragrunt.hcl  # Root config (Backend & Provider)
│       └── dev/            # Development Environment
├── lambdas/
│   ├── public-api/         # Public Python Code
│   └── private-api/        # Private Python Code
└── .github/
    └── workflows/          # CI/CD Pipelines
```

---

---
*Solution by [Lincoln Melo]*
