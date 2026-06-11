# Auto-Scaling Containerized EC2 Architecture

## Overview
This project simulates a production-grade like web infrastructure on AWS. The goal was to 
build something that could handle traffic spikes automatically without manual intervention and added launched template using  Infrastructure as Code.

An Nginx app runs inside Docker containers, with images stored in ECR. When a new EC2 
instance spins up, a User Data bash script pulls the latest image and starts the container 
automatically — no SSH, no manual setup.

Auto Scaling is triggered by CloudWatch when CPU hits 80%, with SNS sending email alerts 
in real time. Load testing was done using stress-ng to verify the scaling actually fired 
under simulated production load.

Built to understand how large-scale systems handle unpredictable traffic 
without downtime — and to get hands-on with AWS autoscaling beyond just 
reading the docs.



## Architecture
![Architecture Diagram](docs/Architecture_diagra.png)

## Tech Stack
- AWS EC2, Auto Scaling Groups
- ALB
- Bash
- Docker
- ECR
- Cloudwatch
- SNS

## Features
- **Zero-downtime deployments** — the application scales up or down automatically as traffic changes, with no interruptions
- **Fully hands-off EC2 provisioning** — launch templates and bash scripts handle everything, so you never manually set up an instance
- **Smart instance initialization** that runs automatically every time a new instance spins up:
  - System patches and updates
  - Docker gets installed and ready
  - AWS CLI v2 set up for seamless AWS integration
  - Automatically pulls the latest container image from ECR and launches it
  
## Prerequisites
- AWS account with appropriate IAM permissions
- ECR repository created
- SNS topic configured for email alerts

## How to Run
Step by step commands to deploy this

## What I Learned
Honest reflection — interviewers love this
