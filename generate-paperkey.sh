#!/bin/bash

set -e

# Check if username and password are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <username> <password>"
  echo "This script logs into Keybase and generates a paperkey."
  exit 1
fi

USERNAME="$1"
PASSWORD="$2"

# Check if keybase is installed
if ! command -v keybase &> /dev/null; then
  echo "Error: Keybase is not installed in this container."
  exit 1
fi

echo "Starting Keybase service..."
keybase service &
sleep 5

echo "Logging in to Keybase as $USERNAME..."
expect << EOF
spawn keybase login
expect "Username: "
send "$USERNAME\r"
expect "Password: "
send "$PASSWORD\r"
expect "Enter a public name for this device: "
send "concourse-resource\r"
expect eof
EOF

echo "Generating paperkey..."
keybase paperkey

echo "Done! Copy the paperkey above and keep it safe."
echo "This paperkey provides full access to your Keybase account."
