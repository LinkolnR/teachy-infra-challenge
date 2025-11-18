# 🚀 Infrastructure Code Challenge

Welcome to the **Teachy Infrastructure Code Challenge**! 🎯

This challenge is designed to assess your skills in infrastructure as code, AWS services, and CI/CD practices. You'll be building a complete serverless architecture with proper networking, security, and automation.

## 📋 Challenge Objective

Your task is to design and implement a secure, scalable infrastructure solution on AWS using Terraform. The solution should include a VPC with proper networking, two Lambda functions (one publicly accessible and one accessible only through VPN), an Application Load Balancer, CloudWatch logging, and a complete CI/CD pipeline.

## 🏗️ What You'll Build

You'll create an infrastructure that demonstrates:

- **Networking**: Proper VPC configuration with public and private subnets
- **Serverless Functions**: Two Lambda functions with different access patterns
- **Load Balancing**: Application Load Balancer for routing traffic
- **Security**: VPN-based access control for private resources
- **Observability**: CloudWatch logging integration
- **Automation**: Complete CI/CD pipeline with Docker builds and automated deployment

**Estimated Time**: 4-6 hours (depending on experience level)

---

## ✅ Requirements Checklist

Your solution must include the following components:

### Core Requirements

- ✅ **VPC Configuration**
  - Properly configured VPC with public and private subnets
  - Internet Gateway for public subnet access
  - NAT Gateway for private subnet outbound access
  - Appropriate route tables and routing

- ✅ **Lambda Functions** (Choose one language: Python, Go, or Node.js)
  - **Public Lambda**: 
    - Accessible from the internet via ALB
    - Implements a single `/` endpoint
    - Returns a JSON response
  - **Private Lambda**:
    - Accessible only through VPN connection
    - Implements a single `/` endpoint
    - Returns a JSON response
  - Both functions must be deployed as container images

- ✅ **OpenVPN Server**
  - Deployed within your VPC infrastructure
  - Provides VPN access to private resources
  - Properly configured security groups

- ✅ **Application Load Balancer (ALB)**
  - Routes traffic to appropriate Lambda functions
  - Listener configuration for HTTP/HTTPS
  - Target groups for Lambda functions
  - Security groups allowing appropriate access

- ✅ **CloudWatch Logging**
  - Log groups for both Lambda functions
  - Proper log retention configuration
  - Logs should be accessible and queryable

- ✅ **Terraform State Management**
  - State stored in S3 bucket (you must create the bucket manually)
  - Proper state locking configuration (DynamoDB table recommended)
  - Backend configuration in your Terraform code

- ✅ **GitHub Actions CI/CD Pipeline**
  - Docker builds for Lambda functions
  - Push images to GitHub Container Registry (ghcr.io)
  - Automated Terraform plan/apply on merge to main branch
  - Proper secrets management for AWS credentials
  - Workflow should trigger on push/PR events

### ⭐ Bonus Points

- ⭐ **Terragrunt Implementation**: Use Terragrunt for better code organization and DRY principles

---

## 🏛️ Architecture Overview

Your architecture should follow this general structure:

```
┌─────────────────────────────────────────────────────────────────┐
│                         Internet                                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌────────────────┐
                    │  Internet      │
                    │  Gateway       │
                    └────────┬───────┘
                             │
        ┌────────────────────┴────────────────────┐
        │                                          │
        ▼                                          ▼
┌───────────────┐                        ┌───────────────┐
│  Public       │                        │  Private      │
│  Subnet       │                        │  Subnet       │
│               │                        │               │
│  ┌─────────┐  │                        │  ┌─────────┐  │
│  │   ALB   │  │                        │  │OpenVPN  │  │
│  └────┬────┘  │                        │  │ Server  │  │
│       │       │                        │  └────┬────┘  │
│       │       │                        │       │        │
│       ├───────┼────────────────────────┼───────┤        │
│       │       │                        │       │        │
│       ▼       │                        │       ▼        │
│  ┌─────────┐  │                        │  ┌─────────┐  │
│  │ Public  │  │                        │  │ Private │  │
│  │ Lambda  │  │                        │  │ Lambda  │  │
│  └─────────┘  │                        │  └─────────┘  │
│               │                        │               │
│  ┌─────────┐  │                        │               │
│  │   NAT   │  │                        │               │
│  │ Gateway │  │                        │               │
│  └─────────┘  │                        │               │
└───────────────┘                        └───────────────┘
        │                                          │
        └──────────────────┬───────────────────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │     VPC      │
                    └──────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    CloudWatch Logs                           │
│  ┌──────────────────┐         ┌──────────────────┐          │
│  │ Public Lambda    │         │ Private Lambda   │          │
│  │ Log Group        │         │ Log Group        │          │
│  └──────────────────┘         └──────────────────┘          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    VPN Connection                            │
│  User → OpenVPN Server → Private Lambda (via ALB)         │
└─────────────────────────────────────────────────────────────┘
```

### Traffic Flow

1. **Public Access**: Internet → ALB → Public Lambda
2. **Private Access**: User → VPN Connection → OpenVPN Server → ALB → Private Lambda

---

## 🔧 Prerequisites

Before you begin, ensure you have:

- ✅ **AWS Account** with appropriate permissions (IAM, VPC, Lambda, EC2, ALB, CloudWatch, S3, DynamoDB)
- ✅ **Terraform** installed (v1.0+ recommended)
- ✅ **Docker** installed and running
- ✅ **GitHub Account** with repository access
- ✅ **AWS CLI** configured with credentials
- ✅ **Git** installed
- ✅ (Optional) **Terragrunt** installed for bonus points

### AWS Permissions Required

Your AWS credentials should have permissions for:
- VPC (create, modify, delete)
- EC2 (instances, security groups, AMIs)
- Lambda (create, update, invoke)
- Application Load Balancer
- CloudWatch (log groups, log streams)
- S3 (bucket operations for state)
- DynamoDB (for state locking)
- IAM (for Lambda execution roles)

---

## 📝 Implementation Guidelines

### VPC Structure

- Create a VPC with CIDR block (e.g., `10.0.0.0/16`)
- At least 2 public subnets across different Availability Zones
- At least 2 private subnets across different Availability Zones
- Internet Gateway attached to VPC
- NAT Gateway in public subnet for private subnet outbound access
- Route tables:
  - Public route table: routes `0.0.0.0/0` to Internet Gateway
  - Private route table: routes `0.0.0.0/0` to NAT Gateway

### Lambda Functions

**Requirements:**
- Both functions should respond to GET requests on `/` path
- Return JSON responses (e.g., `{"message": "Hello from public lambda"}`)
- Deployed as container images (not zip files)
- Container images stored in GitHub Container Registry
- Appropriate timeout and memory settings
- Environment variables if needed

**Function Structure:**
```
lambdas/
├── public-lambda/
│   ├── Dockerfile
│   ├── handler.py (or .go, or .js)
│   └── requirements.txt (if Python)
└── private-lambda/
    ├── Dockerfile
    ├── handler.py (or .go, or .js)
    └── requirements.txt (if Python)
```

### Application Load Balancer

- Deploy ALB in public subnets
- HTTP listener (port 80) or HTTPS listener (port 443) with certificate
- Two target groups:
  - Public Lambda target group
  - Private Lambda target group
- Security group rules:
  - Allow inbound HTTP/HTTPS from internet (for public access)
  - Allow inbound HTTP/HTTPS from VPN subnet (for private access)

### Security Groups

**ALB Security Group:**
- Inbound: Allow HTTP (80) or HTTPS (443) from `0.0.0.0/0` (public access)
- Inbound: Allow HTTP (80) or HTTPS (443) from VPN subnet CIDR (private access)
- Outbound: Allow all traffic

**Public Lambda Security Group:**
- Inbound: Allow traffic from ALB security group
- Outbound: Allow all traffic

**Private Lambda Security Group:**
- Inbound: Allow traffic from ALB security group (only accessible when request comes from VPN)
- Outbound: Allow all traffic

**OpenVPN Security Group:**
- Inbound: Allow UDP 1194 (OpenVPN port) from `0.0.0.0/0`
- Inbound: Allow SSH (22) from your IP for management
- Outbound: Allow all traffic

### OpenVPN Server

You can deploy OpenVPN using:
- **Option 1**: OpenVPN Access Server AMI from AWS Marketplace
- **Option 2**: EC2 instance with OpenVPN installed via user data script
- **Option 3**: Community AMI with OpenVPN pre-installed

The server should be placed in a public subnet with proper security group rules.

### CloudWatch Logs

- Create log groups for both Lambda functions
- Configure appropriate log retention (e.g., 7 days)
- Ensure Lambda execution roles have permissions to write logs
- Log groups should follow naming convention: `/aws/lambda/<function-name>`

### S3 Backend Configuration

**Manual Steps:**
1. Create an S3 bucket for Terraform state (e.g., `teachy-terraform-state-<your-name>`)
2. Enable versioning on the bucket
3. (Recommended) Create a DynamoDB table for state locking
4. Configure Terraform backend in your code:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-bucket-name"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### GitHub Actions Workflow

Your workflow should:

1. **Build Stage:**
   - Build Docker images for both Lambda functions
   - Tag images appropriately (e.g., `ghcr.io/username/repo:latest`)

2. **Push Stage:**
   - Authenticate to GitHub Container Registry
   - Push images to GHCR

3. **Deploy Stage:**
   - Run `terraform init`
   - Run `terraform plan` (on PRs, show plan output)
   - Run `terraform apply` (on merge to main, auto-apply)

**Workflow Structure:**
```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and push Docker images
        # ... build steps
      - name: Terraform Plan/Apply
        # ... terraform steps
```

**Secrets Required:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `GITHUB_TOKEN`

### Terragrunt (Bonus) 

If implementing Terragrunt:
- Use `terragrunt.hcl` for configuration
- Organize code with DRY principles
- Use environment-specific configurations
- Leverage Terragrunt's dependency management

---

## 🧪 Local Testing Suggestions

### 1. Lambda Function Testing

**Docker-based Testing:**
```bash
# Build and test Lambda function locally
docker build -t public-lambda:test ./lambdas/public-lambda
docker run -p 9000:8080 public-lambda:test

# Test with Lambda Runtime Interface Emulator
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d '{"httpMethod":"GET","path":"/"}'
```

**Language-specific Testing:**
- **Python**: Use `pytest` or `unittest` to test handler logic
- **Go**: Use Go's built-in testing framework
- **Node.js**: Use `jest` or `mocha` for testing

### 2. Terraform Validation

```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Plan without applying
terraform plan

# Check for security issues (if using tfsec or checkov)
tfsec .
# or
checkov -d .
```

### 3. VPN Connection Testing

1. Deploy infrastructure
2. Connect to OpenVPN server using provided credentials
3. Verify you can access private Lambda via ALB endpoint
4. Verify public Lambda is accessible without VPN
5. Verify private Lambda is NOT accessible without VPN

### 4. ALB Endpoint Verification

```bash
# Test public Lambda (should work from anywhere)
curl http://your-alb-endpoint.us-east-1.elb.amazonaws.com/

# Test private Lambda (should only work when connected to VPN)
curl http://your-alb-endpoint.us-east-1.elb.amazonaws.com/private
```

### 5. CloudWatch Log Verification

```bash
# View logs using AWS CLI
aws logs tail /aws/lambda/public-lambda --follow
aws logs tail /aws/lambda/private-lambda --follow

# Or use AWS Console to verify log streams are created
```

### 6. End-to-End Testing

1. **Without VPN:**
   - Public Lambda should be accessible
   - Private Lambda should return 403/404 or be unreachable

2. **With VPN:**
   - Both Lambdas should be accessible
   - Verify responses are correct
   - Check CloudWatch logs for both functions

---

## 📤 Submission Guidelines

### Repository Structure

Your repository should be well-organized. Suggested structure:

```
.
├── README.md                    # Your solution documentation
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline
├── infrastructure/             # Terraform/Terragrunt code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/                # (Optional) Terraform modules
├── lambdas/
│   ├── public-lambda/
│   └── private-lambda/
└── .gitignore
```

### Documentation Requirements

Your README should include:

1. **Setup Instructions**
   - How to set up AWS credentials
   - How to configure S3 backend
   - How to run Terraform/Terragrunt
   - How to set up GitHub Actions secrets

2. **Architecture Description**
   - Brief explanation of your design decisions
   - Diagram or description of your architecture

3. **Testing Evidence**
   - Screenshots or commands showing:
     - Public Lambda accessible from internet
     - Private Lambda accessible only via VPN
     - CloudWatch logs
     - Successful CI/CD pipeline runs

4. **Known Issues/Limitations**
   - Any assumptions made
   - Any limitations of your solution

### How to Demonstrate

Provide evidence that your solution works:

- ✅ Screenshot of ALB endpoint responding (public Lambda)
- ✅ Screenshot of VPN connection established
- ✅ Screenshot of private Lambda accessible via VPN
- ✅ Screenshot of CloudWatch logs
- ✅ Screenshot of successful GitHub Actions run
- ✅ Terraform state in S3 (bucket listing)
- ✅ Container images in GitHub Container Registry

### What to Include

- ✅ Complete Terraform/Terragrunt code
- ✅ Lambda function code (all languages if you implemented multiple)
- ✅ Dockerfiles for Lambda functions
- ✅ GitHub Actions workflow file
- ✅ Comprehensive README with setup and testing instructions
- ✅ `.gitignore` file
- ✅ Any helper scripts or documentation

---

## 💡 Tips & Best Practices

### Code Organization

- Use Terraform modules for reusable components
- Separate environments (dev/staging/prod) if using Terragrunt
- Use variables for all configurable values
- Use outputs to expose important values (ALB endpoint, VPN server IP, etc.)

### Security Considerations

- Never commit AWS credentials or secrets
- Use IAM roles with least privilege principle
- Enable encryption at rest for S3 state bucket
- Use security groups with minimal required access
- Consider using AWS Secrets Manager for sensitive data

### Cost Optimization

- Use `t3.micro` or `t3.small` for OpenVPN server (or use Spot instances)
- Set appropriate Lambda timeout and memory
- Use CloudWatch log retention to avoid long-term storage costs
- Clean up resources after testing

### Common Pitfalls to Avoid

- ❌ Forgetting to configure security groups properly
- ❌ Not setting up proper routing in route tables
- ❌ Missing CloudWatch log permissions for Lambda
- ❌ Not handling Terraform state locking
- ❌ Hardcoding values instead of using variables
- ❌ Not testing VPN connectivity before submission
- ❌ Missing error handling in Lambda functions

### Best Practices

- ✅ Use `terraform fmt` to format code
- ✅ Use `terraform validate` before committing
- ✅ Tag all resources appropriately
- ✅ Document your code with comments
- ✅ Use meaningful variable and resource names
- ✅ Test locally before pushing to GitHub
- ✅ Use feature branches and pull requests

---

## ❓ Questions?

If you have any questions about the challenge requirements, please reach out to the hiring team.

Good luck! 🍀 We're excited to see what you build! 🚀

---

## 📚 Additional Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Lambda Container Images](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html)
- [Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [OpenVPN Access Server](https://openvpn.net/access-server/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/) (for bonus)

---

**Happy Coding!** 💻✨

