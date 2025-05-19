#!/bin/bash

# This script helps test the keybase-notification-resource locally
# It tests sending a message to Keybase using the resource

set -e

# Ensure we're using the bash shell
if [ -z "$BASH_VERSION" ]; then
  exec bash "$0" "$@"
fi

echo "Keybase Notification Resource Test Script"
echo "----------------------------------------"

# Create test directory if it doesn't exist
mkdir -p test

# Check if username and paperkey are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <username> <paperkey> [team] [channel]"
  echo "Example: $0 myuser \"paper key words here\" myteam general"
  exit 1
fi

USERNAME="$1"
PAPERKEY="$2"
TEAM="${3:-}"
CHANNEL="${4:-general}"

# Create a test message file
echo "This is a test message from the keybase-notification-resource." > test/message.txt
echo "Timestamp: $(date)" >> test/message.txt

# Create a test input JSON
cat > test/input.json << EOF
{
  "source": {
    "username": "$USERNAME",
    "paperkey": "$PAPERKEY",
    "team": "$TEAM",
    "default_channel": "$CHANNEL"
  },
  "params": {
    "text": "Test message from keybase-notification-resource at $(date)",
    "text_file": "test/message.txt"
  }
}
EOF

echo "Testing the 'out' script..."
cat test/input.json | ./out .

echo "Test completed."
