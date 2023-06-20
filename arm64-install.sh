#!/bin/bash

# Update system packages
sudo yum update -y

# Install necessary packages
sudo yum install -y git docker python3

# Install Java OpenJDK 11
sudo amazon-linux-extras install java-openjdk11 -y

# Create a Docker group and add the current user to it
sudo usermod -aG docker $USER

# Activate the changes to the current session
newgrp docker

# Alternatively, if the previous command doesn't work, you can use the following command:
# exec sudo su -l $USER

# Set the Java version
sudo /usr/sbin/alternatives --set java /usr/lib/jvm/java-11-openjdk-11.0.7.10-4.amzn2.0.1.aarch64/bin/java

# Install Python pip
sudo yum install python3-pip -y

# Install the Boto3 library
pip3 install boto3

#installing docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Enable Docker
sudo systemctl enable docker
sudo systemctl start docker
