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



## What I Built

🚀 Automatic Scaling – Instances are created automatically when traffic spikes.

🛡️ Self-Healing – Failed instances are automatically replaced to maintain availability.

🔄 Infrastructure as Code – EC2 Launch Templates and AWS infrastructure are provisioned using Terraform.

🐳 Containerized Deployment – Docker images are stored in Amazon ECR and pulled automatically on new instances.

⚙️ Bash Automation – User Data scripts install and configure Docker, AWS CLI, and application dependencies during instance launch.

📊 Smart Monitoring – Amazon CloudWatch monitors system metrics, while Amazon SNS sends alert notifications.

⚡ Zero Downtime Deployments – Application updates are deployed seamlessly without interrupting user traffic.

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

## Architecture Overview

### Application Load Balancer (ALB)

The Application Load Balancer serves as the entry point for incoming traffic and distributes requests across multiple EC2 instances. Health checks are continuously performed to ensure traffic is routed only to healthy instances. Newly launched instances are automatically registered with the load balancer, while unhealthy instances are removed from rotation, improving application availability and fault tolerance.

### Auto Scaling Group (ASG)

The Auto Scaling Group maintains a desired number of EC2 instances and dynamically adjusts capacity based on workload demand. In this architecture this process is done using Infrastructure as code(Iac) and should be added manually. Scaling policies are configured to launch additional instances when CPU utilization exceeds predefined thresholds and terminate unnecessary instances when demand decreases. This ensures efficient resource utilization while maintaining application performance.

### Containerized Application Deployment

The Nginx application is packaged as a Docker container and stored in Amazon Elastic Container Registry (ECR). During instance initialization, an EC2 User Data script automatically:

* Installs Docker
* Authenticates with Amazon ECR using IAM roles
* Pulls the latest container image
* Launches the application container

This automated provisioning process eliminates manual server configuration and guarantees consistent deployments across all instances.

### Monitoring and Alerting

Amazon CloudWatch is used to monitor infrastructure and application metrics, including CPU utilization, network traffic, and instance health. CloudWatch alarms are integrated with Amazon SNS to provide real-time email notifications when predefined thresholds are breached, enabling proactive incident response and operational visibility.

### Infrastructure as Code with Terraform

The Launch Template used in the infrastructure is created using terraform and it should be added to the ASG manually .

---

## Auto Scaling Validation

To validate the effectiveness of the auto-scaling configuration, load-testing exercises were conducted by generating sustained CPU-intensive workloads on EC2 instances.

### Testing Procedure

1. Connect to a running EC2 instance via SSH.
2. Install a stress-testing utility.
3. Generate CPU load for a defined duration.
4. Monitor Auto Scaling Group activity, CloudWatch metrics, and load balancer target health.

## Cost Optimization Considerations

The architecture is designed with scalability and cost efficiency in mind.

* Utilizes cost-effective EC2 instance types suitable for web workloads.
* Maintains a minimum instance count to ensure high availability.
* Dynamically scales resources based on demand to prevent over-provisioning.
* Supports migration to EC2 Spot Instances for additional cost savings where workload interruption is acceptable.
* Minimizes operational overhead through automation and Infrastructure as Code practices.

By combining automated scaling, containerization, monitoring, and Infrastructure as Code, this solution demonstrates a production-oriented AWS architecture capable of delivering high availability, operational efficiency, and scalable application deployment.

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

## Files

```
.
├── docker/                      ← You are here
│   └── index.html             
├── docs/                  # Your app in a box
    └── Architecture_diagra.png
├── terraform/
│   ├── main.tf
|   ├── user_data.sh               
│   ├── vars.tf             
│   ├── outputs.tf               # What Terraform gives back
│   ├── terraform.tfvars         # Your actual config values
│   └──            
├── Dockerfile
├── LICENSE
├── README.md


```

---

