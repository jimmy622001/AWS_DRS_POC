#!/bin/bash

# Create zip files for Lambda functions
mkdir -p dist
zip -r dist/enable_security.zip enable_security.js
zip -r dist/disable_security.zip disable_security.js

# Copy zip files to parent directory
cp dist/enable_security.zip ../enable_security.zip
cp dist/disable_security.zip ../disable_security.zip

echo "Lambda function zip files created successfully!"