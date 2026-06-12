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

### Step 1: Grab the Code
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

The Auto Scaling Group maintains a desired number of EC2 instances and dynamically adjusts capacity based on workload demand. Scaling policies are configured to launch additional instances when CPU utilization exceeds predefined thresholds and terminate unnecessary instances when demand decreases. This ensures efficient resource utilization while maintaining application performance.

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

All cloud resources are provisioned and managed using Terraform. Infrastructure components, including networking, compute resources, load balancing, monitoring, and scaling policies, are defined declaratively in Terraform configuration files. This approach enables version control, repeatable deployments, team collaboration, and simplified infrastructure management.

---

## Auto Scaling Validation

To validate the effectiveness of the auto-scaling configuration, load-testing exercises were conducted by generating sustained CPU-intensive workloads on EC2 instances.

### Testing Procedure

1. Connect to a running EC2 instance via SSH.
2. Install a stress-testing utility.
3. Generate CPU load for a defined duration.
4. Monitor Auto Scaling Group activity, CloudWatch metrics, and load balancer target health.

### Observed Results

* CPU utilization increased beyond the configured scaling threshold.
* CloudWatch alarms were triggered successfully.
* The Auto Scaling Group launched additional EC2 instances automatically.
* Newly launched instances completed initialization, passed health checks, and began serving traffic through the load balancer.
* After workload reduction, excess instances were terminated according to scaling policies.

This validation confirmed the architecture's ability to automatically adapt to changing traffic conditions while maintaining application availability.

---

## Monitoring Strategy

The following operational metrics are continuously monitored:

* CPU Utilization
* Network Throughput
* Healthy Host Count
* Load Balancer Request Count
* Auto Scaling Group Activity

CloudWatch dashboards provide centralized visibility into infrastructure performance, while SNS notifications ensure critical events are communicated promptly to administrators.

---

## Cost Optimization Considerations

The architecture is designed with scalability and cost efficiency in mind.

* Utilizes cost-effective EC2 instance types suitable for web workloads.
* Maintains a minimum instance count to ensure high availability.
* Dynamically scales resources based on demand to prevent over-provisioning.
* Supports migration to EC2 Spot Instances for additional cost savings where workload interruption is acceptable.
* Minimizes operational overhead through automation and Infrastructure as Code practices.

By combining automated scaling, containerization, monitoring, and Infrastructure as Code, this solution demonstrates a production-oriented AWS architecture capable of delivering high availability, operational efficiency, and scalable application deployment.

## Security (Doing It Right)

✅ **IAM Roles** - Instances only get permissions they need, nothing more  
✅ **Security Groups** - Only the load balancer can talk to instances  
✅ **No Secrets in Code** - ECR authentication uses IAM, not hardcoded passwords  
✅ **Terraform State** - Store in S3 with encryption enabled  
✅ **Health Checks** - Dead or unhealthy instances don't get traffic  

Basically, following the principle: "Give things the minimum they need to work, nothing more."  

## File Structure

```
.
├── README.md
├── Dockerfile              # Nginx container definition
├── docker/                 # Application source files
│   └── index.html
├── terraform/
│   ├── main.tf
│   ├── launch_template.tf
│   ├── scaling_policy.tf
│   ├── cloudwatch.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── user_data.sh        # Instance initialization script
└── scripts/
    └── stress_test.sh      # Load testing script
```

## When You're Done (Kill It All)

Don't forget—AWS will keep charging you while resources are running. Tear it down when done:
```bash
cd terraform/
terraform destroy
```

Terraform will show you everything it's about to delete. Say yes, and in a few minutes everything's gone and you stop bleeding money.

## What I Learned 

* **Implemented Infrastructure as Code (IaC):** Leveraged Terraform to automate the provisioning of launch template, enabling consistent, repeatable. This approach significantly reduced manual configuration efforts and allowed the entire environment to be recreated quickly when required.

* **Automated Instance Configuration:** Utilized EC2 User Data scripts to automatically install and configure Docker during instance launch. This eliminated the need for manual server setup, improved deployment consistency, and reduced operational overhead.

* **Established Proactive Monitoring:** Configured Amazon CloudWatch alarms and SNS notifications to monitor infrastructure health and resource utilization. This ensured timely alerting and improved operational visibility for potential issues.

* **Validated Auto Scaling Functionality:** Conducted load-testing exercises to simulate increased application traffic and verify Auto Scaling behavior. Successfully observed dynamic provisioning of additional EC2 instances, confirming the architecture's ability to maintain performance and availability under varying workloads.



## What's Next?

This is version 1.0. Here are ideas for making it even better:

- **Multi-region failover** - If AWS's entire us-east-1 region explodes, automatically fail over to us-west-2
- **Spot Instances** - Cut costs by 70% (but trade risk of interruption)
- **Kubernetes (EKS)** - If your app gets bigger, move to container orchestration
- **CI/CD Pipeline** - Every GitHub push automatically rebuilds the Docker image and deploys it
- **Smarter Scaling** - Instead of just CPU, scale based on request count or custom metrics
- **Blue-Green Deployments** - Swap traffic between two identical environments for zero-downtime updates

## Questions? Issues?

- Check the AWS docs if something breaks
- Read the Terraform code—it's self-documenting
- Run `terraform plan` before `apply` to see what's changing

## Files

```
.
├── README.md                    ← You are here
├── Dockerfile                   # Your app in a box
├── docker/
│   └── index.html              # Simple demo page
├── terraform/
│   ├── main.tf                 # VPC, load balancer, networking
│   ├── launch_template.tf       # EC2 instance configuration
│   ├── scaling_policy.tf        # When to scale up/down
│   ├── cloudwatch.tf            # Alarms and dashboards
│   ├── variables.tf             # Inputs you can customize
│   ├── outputs.tf               # What Terraform gives back
│   ├── terraform.tfvars         # Your actual config values
│   └── user_data.sh             # What runs when instances boot
└── scripts/
    └── stress_test.sh           # Load testing script
```

---

**Built with ❤️ to eliminate manual DevOps work**

Questions? Open an issue. Found a bug? PR welcome.
