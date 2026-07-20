#!/bin/bash
set -e

# Update system packages
yum update -y

# Install Apache web server
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple health check page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>EC2 Instance</title>
</head>
<body>
    <h1>Welcome to EC2 Instance</h1>
    <p>Environment: ${environment}</p>
    <p>Instance is running successfully!</p>
</body>
</html>
EOF

# Log completion
echo "User data script completed at $(date)" >> /var/log/user-data.log
