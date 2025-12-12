#!/bin/bash

# This script prepares all necessary resources for the AWS DRS POC project

# Set up the on-demand security Lambda functions
echo "Building On-Demand Security Lambda functions..."
cd modules/on_demand_security/lambda
npm install
bash build.sh
cd ../../..

echo "Setup complete!"
echo "You can now run 'terraform init' and 'terraform apply' to deploy the infrastructure."