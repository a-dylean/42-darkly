#!/bin/bash

echo "Setting up Python environment for explore_hidden.py"
echo "=================================================="

echo "Note: Make sure your target server (localhost:8080) is running"
echo "      Adjust the base_url in the script if needed"

target_url="http://localhost:8080/.hidden/"
# Check if the target URL is reachable
if ! curl -s --head --request GET "$target_url" | grep "200 OK" > /dev/null; then
    echo "Error: Target URL $target_url is not reachable. Please ensure the server is running."
    exit 1
fi

# Check if explore_hidden.py exists
if [ ! -f "explore_hidden.py" ]; then
    echo "Error: explore_hidden.py not found in the current directory."
    exit 1
fi


# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Python3 is not installed. Please install Python3 first."
    exit 1
fi

# Source virtual environment if it exists, otherwise create one
if [ -d "venv" ]; then
    echo "Activating existing virtual environment..."
    source venv/bin/activate
else
    echo "Creating a new virtual environment..."
    python3 -m venv venv
    source venv/bin/activate
fi

# Install required packages
echo "Installing required Python packages..."
pip3 install -r requirements.txt

# Run the script
python3 explore_hidden.py
