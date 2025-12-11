#!/bin/bash
# Setup script for application servers in the DR environment
# This script will be run on EC2 instances during initialization

# Exit on error
set -e

# Log setup
LOG_FILE="/var/log/dr_setup.log"
exec > >(tee -a ${LOG_FILE}) 2>&1

echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting DR server setup"

# Update system
echo "Updating system packages"
yum update -y

# Install common utilities
echo "Installing common utilities"
yum install -y \
    amazon-cloudwatch-agent \
    aws-cli \
    jq \
    unzip \
    htop \
    ntp \
    telnet \
    tcpdump

# Setup CloudWatch agent
echo "Configuring CloudWatch agent"
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/dr_setup.log",
            "log_group_name": "DR-App-Setup-Logs",
            "log_stream_name": "{instance_id}-setup",
            "retention_in_days": 14
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "DR-App-System-Logs",
            "log_stream_name": "{instance_id}-messages",
            "retention_in_days": 14
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      }
    },
    "append_dimensions": {
      "InstanceId": "\${aws:InstanceId}",
      "InstanceType": "\${aws:InstanceType}",
      "AutoScalingGroupName": "\${aws:AutoScalingGroupName}"
    }
  }
}
EOF

# Start CloudWatch agent
echo "Starting CloudWatch agent"
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Setup NTP for time synchronization
echo "Configuring NTP"
systemctl enable ntpd
systemctl start ntpd

# Retrieve instance tags
echo "Retrieving instance tags"
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

echo "Getting tags for instance $INSTANCE_ID in region $REGION"
SERVER_ROLE=$(aws ec2 describe-tags --region $REGION --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=ServerRole" --output text --query 'Tags[0].Value' || echo "unknown")

# Configure server based on role
echo "Configuring server for role: $SERVER_ROLE"

case $SERVER_ROLE in
    "web")
        echo "Setting up web server"
        yum install -y httpd php php-mysql
        systemctl enable httpd
        systemctl start httpd
        
        # Create a health check page
        cat <<EOF > /var/www/html/health.php
<?php
header("Content-Type: application/json");
echo json_encode([
    "status" => "healthy", 
    "timestamp" => time(),
    "server_id" => "$INSTANCE_ID",
    "environment" => "dr"
]);
?>
EOF
        ;;
    "app")
        echo "Setting up application server"
        # Install Java for application servers
        yum install -y java-11-amazon-corretto
        
        # Create app directory
        mkdir -p /opt/banking-app
        chmod 755 /opt/banking-app
        
        # Create a simple startup script
        cat <<EOF > /opt/banking-app/start.sh
#!/bin/bash
echo "Banking application would start here in DR mode"
# In a real scenario, this would fetch application files from S3
# and start the application with appropriate DR configuration
EOF
        chmod +x /opt/banking-app/start.sh
        ;;
    "db")
        echo "Setting up database auxiliary server"
        # Install MySQL client tools
        yum install -y mariadb
        
        # Create utilities directory
        mkdir -p /opt/db-utils
        
        # Create database monitoring script
        cat <<EOF > /opt/db-utils/check_rds.sh
#!/bin/bash
# Simple script to check connectivity to RDS
# In a real scenario, this would be more sophisticated

RDS_ENDPOINT=\$1

if [ -z "\$RDS_ENDPOINT" ]; then
    echo "Usage: \$0 <rds-endpoint>"
    exit 1
fi

echo "Checking connectivity to \$RDS_ENDPOINT..."
nc -zv \$RDS_ENDPOINT 3306
EOF
        chmod +x /opt/db-utils/check_rds.sh
        ;;
    *)
        echo "Unknown server role: $SERVER_ROLE - setting up with basic configuration"
        ;;
esac

# Setup AWS CLI config for SSM access to parameters
echo "Configuring AWS CLI for SSM access"
mkdir -p /root/.aws
cat <<EOF > /root/.aws/config
[default]
region = $REGION
EOF

# Set up CloudWatch custom metrics for DR status
echo "Setting up custom DR health metrics"
cat <<EOF > /opt/aws/dr_health_check.sh
#!/bin/bash
# Script to report custom DR health metrics

# Check connectivity to key services and report metrics
aws cloudwatch put-metric-data \\
  --namespace BankingDR \\
  --metric-name ServerHealth \\
  --dimensions ServerRole=$SERVER_ROLE,InstanceId=$INSTANCE_ID \\
  --value 1

# In a real scenario, would perform actual health checks
# and report appropriate values (0 for unhealthy, 1 for healthy)
EOF
chmod +x /opt/aws/dr_health_check.sh

# Set up cron to run health check every 5 minutes
echo "Setting up cron job for health check"
echo "*/5 * * * * /opt/aws/dr_health_check.sh" > /tmp/dr-crontab
crontab /tmp/dr-crontab

echo "$(date '+%Y-%m-%d %H:%M:%S') - DR server setup completed successfully"