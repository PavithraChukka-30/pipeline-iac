#!/bin/bash
set -e

# swap, because t3.micro has only 1 GB RAM
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# docker and git
apt-get update -y
apt-get install -y docker.io git
systemctl enable --now docker

# Jenkins image with Terraform included
mkdir -p /opt/jenkins && cd /opt/jenkins
cat > Dockerfile <<'EOF'
FROM jenkins/jenkins:lts
USER root
RUN apt-get update && apt-get install -y unzip curl \
 && curl -fsSL https://releases.hashicorp.com/terraform/1.10.5/terraform_1.10.5_linux_amd64.zip -o /tmp/tf.zip \
 && unzip /tmp/tf.zip -d /usr/local/bin && rm /tmp/tf.zip
USER jenkins
EOF
docker build -t my-jenkins .

docker run -d --name jenkins --restart unless-stopped \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home my-jenkins