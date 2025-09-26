#!/bin/bash

echo "Setting up Python environment for explore_hidden.py"
echo "=================================================="

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 is not installed. Please install Python3 first."
    exit 1
fi

# Install required packages
echo "Installing required Python packages..."
pip3 install -r requirements.txt

echo ""
echo "Setup complete!"
echo "You can now run the script with: python3 explore_hidden.py"
echo ""
echo "Note: Make sure your target server (localhost:8080) is running"
echo "      Adjust the base_url in the script if needed"
