#!/bin/bash

set -e

# Check if username and paperkey are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <username> <paperkey> <recipient> [channel]"
  echo "This script tests the keybase-notification-resource Docker image."
  echo ""
  echo "Examples:"
  echo "  # Send to a team channel"
  echo "  $0 myuser \"paper key words\" myteam general"
  echo ""
  echo "  # Send to a user"
  echo "  $0 myuser \"paper key words\" anotheruser"
  exit 1
fi

USERNAME="$1"
PAPERKEY="$2"
RECIPIENT="$3"
CHANNEL="${4:-}"

# Determine if recipient is a team or a user
if [[ "$RECIPIENT" == *"@"* ]]; then
  # It's an email, so it's a user
  IS_TEAM=false
else
  # Check if there's a channel parameter
  if [ -n "$CHANNEL" ]; then
    IS_TEAM=true
  else
    # No channel, assume it's a user
    IS_TEAM=false
    CHANNEL="$RECIPIENT"
    RECIPIENT=""
  fi
fi

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Create a test message
echo "This is a test message from the keybase-notification-resource Docker image." > "$TEMP_DIR/message.txt"
echo "Timestamp: $(date)" >> "$TEMP_DIR/message.txt"

# Create a test input JSON
if [ "$IS_TEAM" = true ]; then
  # Create JSON for team message
  cat > "$TEMP_DIR/input.json" << EOF
{
  "source": {
    "username": "$USERNAME",
    "paperkey": "$PAPERKEY",
    "team": "$RECIPIENT"
  },
  "params": {
    "text": "Test message from keybase-notification-resource Docker image at $(date)",
    "channel": "$CHANNEL"
  }
}
EOF
  echo "Testing the keybase-notification-resource Docker image..."
  echo "Sending a message to team: $RECIPIENT, channel: $CHANNEL"
else
  # Create JSON for user message
  cat > "$TEMP_DIR/input.json" << EOF
{
  "source": {
    "username": "$USERNAME",
    "paperkey": "$PAPERKEY"
  },
  "params": {
    "text": "Test message from keybase-notification-resource Docker image at $(date)",
    "channel": "$CHANNEL"
  }
}
EOF
  echo "Testing the keybase-notification-resource Docker image..."
  echo "Sending a message to user: $CHANNEL"
fi

# Run the Docker container with the test input
cat "$TEMP_DIR/input.json" | docker run --rm -i \
  -v "$TEMP_DIR:/tmp/test" \
  my-registry/keybase-resource:latest \
  /opt/resource/out /tmp/test

echo "Test completed."
