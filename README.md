# Auto-Scaling Containerized Web Application on AWS

## Overview

This project simulates a production-grade like web infrastructure on AWS. The goal was to build something that could handle traffic spikes automatically without manual intervention.

An Nginx app runs inside Docker containers, with images stored in ECR. When a new EC2 instance spins up, a User Data bash script pulls the latest image and starts the container automatically — no SSH, no manual setup.

Auto Scaling is triggered by CloudWatch when CPU hits 80%, with SNS sending email alerts in real time. Load testing was done using stress-ng to verify the scaling actually fired under simulated production load.

Built to understand how large-scale systems handle unpredictable traffic without downtime — and to get hands-on with AWS autoscaling beyond just reading the docs.

## Architecture Diagram

![Architecture Diagram](docs/Architecture_diagra.png)

## How It All Works Together

When someone visits your app:
1. Their request hits the **Load Balancer** (traffic cop)

2. Gets routed to the healthiest **EC2 instance** in the group

3. That instance runs your **containerized app** (stored in ECR)

4. If CPU gets too high, more instances spin up automatically

5. You get notified via email if anything looks off

## Before You Start

You'll need:
- An AWS account (with permission to create EC2, VPC, load balancers)
- [Terraform](https://www.terraform.io/downloads.html) installed
- [Docker](https://www.docker.com/products/docker-desktop)
- [AWS CLI](https://aws.amazon.com/cli/) set up with your credentials
  
## Get It Running (5 Minutes)

### Step 1: Clone the Repo
```bash
git clone https://github.com/yourusername/aws-autoscaling-app.git
cd aws-autoscaling-app
```

### Step 2: Push Your App to ECR
First, create a container repository in AWS:
```bash
aws ecr create-repository --repository-name nginx-app --region us-east-1
```

Then build and push your Docker image:
```bash
docker build -t nginx-app:latest .
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <YOUR_AWS_ID>.dkr.ecr.us-east-1.amazonaws.com
docker tag nginx-app:latest <YOUR_AWS_ID>.dkr.ecr.us-east-1.amazonaws.com/nginx-app:latest
docker push <YOUR_AWS_ID>.dkr.ecr.us-east-1.amazonaws.com/nginx-app:latest
```

### Step 3: Deploy Everything with Terraform
```bash
cd terraform/
terraform init          # First time only - sets up Terraform
terraform plan          # See what's about to be created
terraform apply         # Go! Creates load balancer, instances, alarms, etc.
```

### Step 4: Test It
Test the Architecture with using the ALB Link in browser or use curl in linux
```bash
curl http://<YOUR-ALB-ADDRESS>
```

Done! Your app is now live and auto-scaling. ✅

## Security 

✅ **IAM Roles** - Instances only get permissions they need.

✅ **Security Groups** - Only the load balancer can talk to instances  

✅ **No Secrets in Code** - ECR authentication uses IAM, not hardcoded passwords

✅ **Health Checks** - unhealthy instances don't get traffic  

## What I Learned 

* **Implemented Infrastructure as Code (IaC):** Leveraged Terraform to automate the provisioning of launch template, enabling consistent, repeatable. This approach significantly reduced manual configuration efforts and allowed the entire environment to be recreated quickly when required.

* **Automated Instance Configuration:** Utilized EC2 User Data scripts to automatically install and configure Docker during instance launch. This eliminated the need for manual server setup, improved deployment consistency, and reduced operational overhead.

* **Established Proactive Monitoring:** Configured Amazon CloudWatch alarms and SNS notifications to monitor infrastructure health and resource utilization. This ensured timely alerting and improved operational visibility for potential issues.

* **Validated Auto Scaling Functionality:** Conducted load-testing exercises to simulate increased application traffic and verify Auto Scaling behavior. Successfully observed dynamic provisioning of additional EC2 instances, confirming the architecture's ability to maintain performance and availability under varying workloads.

## File Structure

```
.
├── docker/                      
│   └── index.html             
├── docs/                  
|   └── Architecture_diagra.png
├── terraform/
│   ├── main.tf
|   ├── user_data.sh               
│   ├── vars.tf             
│   ├── outputs.tf               
│   └── terraform.tfvars  #add this file in .gitignore
├── .gitignore            
├── Dockerfile
├── LICENSE
├── README.md


```

---

