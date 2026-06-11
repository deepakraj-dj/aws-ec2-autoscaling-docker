#!/bin/bash
ECR_REGISTRY=333372137025.dkr.ecr.us-east-1.amazonaws.com/portfolio/test:latest
AWS_CLI_Link="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" 
sudo apt update -y
sudo apt install unzip -y
sudo apt install docker.io -y 
curl "${AWS_CLI_Link}" -o awscliv2.zip
unzip awscliv2.zip
./aws/install
sudo systemctl start docker 
while ! sudo systemctl is-active --quiet docker; do
    sleep 1
done
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 333372137025.dkr.ecr.us-east-1.amazonaws.com
docker pull $ECR_REGISTRY
docker run -d -p 80:80 $ECR_REGISTRY

