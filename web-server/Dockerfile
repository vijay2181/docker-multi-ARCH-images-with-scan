# Use the Amazon Linux 2 base image
FROM amazonlinux:2

# Install dependencies
RUN yum update -y && \
    yum install -y httpd

# Expose port 80
EXPOSE 80

# Copy custom index.html to Apache's default web directory
COPY index.html /var/www/html/index.html

# Start the Apache service
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
