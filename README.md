# Auto-Scaling Containerized Web Application on AWS

A production-ready, highly available web application deployed on AWS with automatic scaling, load balancing, and infrastructure-as-code using Terraform.

## Architecture Overview
![Architecture Diagram](docs/Architecture_diagra.png)

## Key Features

✅ **High Availability & Fault Tolerance** - Multi-AZ deployment with automatic instance replacement  
✅ **Automatic Scaling** - Scales out at 80% CPU, scales in during low traffic  
✅ **Infrastructure as Code** - Terraform-managed deployments from GitHub  
✅ **Containerization** - Docker-based Nginx app stored in Amazon ECR  
✅ **Real-Time Monitoring** - CloudWatch alarms with SNS email alerts  
✅ **Zero-Downtime Deployments** - Rolling updates via ALB health checks  

## Prerequisites

- AWS Account with appropriate IAM permissions
- Terraform >= 1.0
- Docker (for building container images)
- AWS CLI configured with credentials
- GitHub repository for version control

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/aws-autoscaling-app.git
cd aws-autoscaling-app
```

### 2. Build & Push Docker Image to ECR
```bash
# Create ECR repository
aws ecr create-repository --repository-name nginx-app --region us-east-1

# Build and push image
docker build -t nginx-app:latest .
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
docker tag nginx-app:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/nginx-app:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/nginx-app:latest
```

### 3. Deploy Infrastructure with Terraform
```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

### 4. Verify Deployment
```bash
# Get ALB DNS name
aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[0].DNSName'

# Test the application
curl http://<ALB-DNS-NAME>
```

## Project Components

### EC2 & Auto Scaling Group
- **Launch Template**: Defines instance configuration with User Data script
- **Auto Scaling Policy**: Scales out at 80% CPU, scales in at 20% CPU
- **Min/Max Instances**: 2-6 instances for cost optimization and availability

### Application Load Balancer (ALB)
- Distributes traffic across healthy instances
- Health checks on port 80 every 30 seconds
- Target group automatically updated as instances scale

### Docker & ECR
- **Dockerfile**: Minimal Nginx image with custom content
- **User Data Script**: Automatically pulls latest image from ECR on instance launch
- **Authentication**: Instances use IAM roles to authenticate with ECR (no hardcoded credentials)

### CloudWatch & SNS
- **CPU Alarm**: Triggers when utilization exceeds 80%
- **Email Notifications**: SNS sends alerts to admin email
- **Dashboard**: Custom CloudWatch dashboard for monitoring metrics

### Terraform (IaC)
```
terraform/
├── main.tf              # ALB, ASG, VPC resources
├── launch_template.tf   # EC2 launch template with User Data
├── scaling_policy.tf    # Auto-scaling rules
├── cloudwatch.tf        # Alarms and monitoring
├── variables.tf         # Input variables
├── outputs.tf           # Output values
└── terraform.tfvars     # Configuration values
```

## Testing & Validation

### Simulate High CPU Load
```bash
# SSH into an EC2 instance
ssh -i your-key.pem ec2-user@<instance-ip>

# Install and run stress-ng
sudo yum install -y stress-ng
stress-ng --cpu 4 --timeout 300s --verbose

# Monitor scaling in AWS Console
# - Watch Auto Scaling Group metrics
# - Check CloudWatch alarms
# - Verify new instances are launched and registered
```

### Expected Behavior
1. CPU load increases to >80%
2. CloudWatch alarm triggers
3. ASG launches new instances (2-3 min)
4. ALB registers new instances after health checks pass
5. Load distributes across all instances
6. Instances terminate when load decreases

## Monitoring & Alerts

### CloudWatch Metrics
- CPU Utilization (per instance & average)
- Network In/Out
- Target Group Health
- Active Connection Count

### SNS Email Alerts
Configure email address in Terraform:
```hcl
sns_email = "your-email@example.com"
```

## Cost Optimization

- **Right-Sizing**: Uses t3.medium instances (burstable, cost-effective)
- **Min Instances**: 2 for high availability, not over-provisioned
- **Scaling Thresholds**: Conservative to avoid unnecessary scaling costs
- **On-Demand Pricing**: Can be switched to Spot instances for 70% savings

## Security Best Practices

✅ IAM roles with minimal permissions (principle of least privilege)  
✅ Security groups restrict traffic to ALB only  
✅ No credentials in code or User Data (ECR auth via IAM)  
✅ Terraform state secured in S3 with encryption  
✅ Health checks ensure only healthy instances receive traffic  

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

## Cleanup

To avoid AWS charges, destroy all resources:
```bash
cd terraform/
terraform destroy
```

## Lessons Learned

- **Infrastructure as Code**: Terraform enables repeatable, version-controlled deployments
- **Container Automation**: User Data scripts eliminate manual setup on every instance
- **Proactive Monitoring**: CloudWatch alarms catch issues before they impact users
- **Testing in Production**: Load testing validates auto-scaling behavior under real conditions

## Future Improvements

- [ ] Multi-region failover with Route 53
- [ ] Spot instances for cost optimization
- [ ] Container orchestration with ECS/EKS
- [ ] CI/CD pipeline with GitHub Actions
- [ ] Custom metrics for smarter scaling decisions
- [ ] Blue-green deployments for zero-downtime updates

## References

- [AWS Auto Scaling Documentation](https://docs.aws.amazon.com/autoscaling/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## Author

Your Name - [GitHub Profile](https://github.com/yourusername)

## License

MIT License - see LICENSE file for details

