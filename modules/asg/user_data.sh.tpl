#!/bin/bash
set -e

sudo yum update -y

sudo amazon-linux-extras install docker -y
sudo service docker start
sudo chkconfig docker on
sudo usermod -a -G docker ec2-user

sudo yum install -y unzip

sudo yum remove -y aws-cli || true

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

rm -rf aws awscliv2.zip

aws configure set aws_access_key_id "${access_key}"
aws configure set aws_secret_access_key "${secret_key}"
aws configure set region "${region}"

aws ecr get-login-password --region "${region}" | docker login --username AWS --password-stdin "${account_id}.dkr.ecr.${region}.amazonaws.com"
