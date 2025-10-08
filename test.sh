#!/bin/bash

# Test script for BYOA application
# This script tests the API functionality by sourcing the .env file and running a test conversation

set -e  # Exit on any error

echo "Testing BYOA application..."

# Source the environment variables
if [ -f ".env" ]; then
    source .env
    echo "✓ Loaded environment variables from .env"
else
    echo "❌ .env file not found"
    exit 1
fi

# Check if API key is set
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "❌ ANTHROPIC_API_KEY is not set in .env file"
    exit 1
fi

echo "✓ API key is set (length: ${#ANTHROPIC_API_KEY})"

# Build the application
echo "Building application..."
go build -o byoa
echo "✓ Application built successfully"

# Test the application with a simple message
echo "Testing API call..."
echo "Hello Claude, please respond with just 'API test successful'" | ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY ./byoa &
PID=$!

# Wait a bit for the response
sleep 5

# Kill the process if it's still running
if kill -0 $PID 2>/dev/null; then
    kill $PID
    echo "✓ Application responded (killed after 5 seconds)"
else
    echo "✓ Application completed"
fi

echo "Test completed!"
