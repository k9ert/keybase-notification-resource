#!/bin/bash

# This script sends a message to Keybase using the Keybase API
# It uses curl to make HTTP requests to the Keybase API

# Parse JSON input from stdin
INPUT=$(cat)

# Extract parameters using jq
USERNAME=$(echo "$INPUT" | jq -r '.username')
PAPERKEY=$(echo "$INPUT" | jq -r '.paperkey')
TEAM=$(echo "$INPUT" | jq -r '.team')
CHANNEL=$(echo "$INPUT" | jq -r '.channel')
MESSAGE=$(echo "$INPUT" | jq -r '.message')
SILENT=$(echo "$INPUT" | jq -r '.silent // false')

# Validate required parameters
if [ -z "$USERNAME" ] || [ -z "$PAPERKEY" ] || [ -z "$MESSAGE" ]; then
  echo "Error: username, paperkey, and message are required" >&2
  exit 1
fi

# If team is not provided, assume direct message to user in channel
if [ -z "$TEAM" ] && [ -z "$CHANNEL" ]; then
  echo "Error: either team or channel must be provided" >&2
  exit 1
fi

# Function to send a message to a Keybase team channel
send_message() {
  local username="$1"
  local paperkey="$2"
  local team="$3"
  local channel="$4"
  local message="$5"
  local silent="$6"

  # Create a temporary directory for the keybase config
  TEMP_DIR=$(mktemp -d)

  # Prepare the message payload
  if [ -n "$team" ]; then
    # Team message
    PAYLOAD=$(cat << EOF
{
  "method": "send",
  "params": {
    "options": {
      "channel": {
        "name": "$team",
        "topic_name": "$channel",
        "members_type": "team"
      },
      "message": {
        "body": "$message"
      }
    }
  }
}
EOF
    )
  else
    # Direct message
    PAYLOAD=$(cat << EOF
{
  "method": "send",
  "params": {
    "options": {
      "channel": {
        "name": "$channel",
        "members_type": "impteamnative"
      },
      "message": {
        "body": "$message"
      }
    }
  }
}
EOF
    )
  fi

  # Send the message using curl
  if [ "$silent" = "true" ]; then
    # Silent mode
    RESPONSE=$(curl -s -X POST \
      -H "X-Keybase-Client: keybase-notification-resource" \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD" \
      "https://keybase.io/_/api/1.0/chat/api" \
      -u "$username:$paperkey" 2>/dev/null)
  else
    # Verbose mode
    echo "Sending message to Keybase..."
    RESPONSE=$(curl -s -X POST \
      -H "X-Keybase-Client: keybase-notification-resource" \
      -H "Content-Type: application/json" \
      -d "$PAYLOAD" \
      "https://keybase.io/_/api/1.0/chat/api" \
      -u "$username:$paperkey")
  fi

  # Check if the request was successful
  STATUS=$(echo "$RESPONSE" | jq -r '.status.code // 500')

  if [ "$STATUS" -eq 0 ]; then
    if [ "$silent" != "true" ]; then
      echo "Message sent successfully"
    fi
    return 0
  else
    ERROR=$(echo "$RESPONSE" | jq -r '.status.desc // "Unknown error"')
    echo "Error sending message: $ERROR" >&2
    return 1
  fi
}

# Send the message
send_message "$USERNAME" "$PAPERKEY" "$TEAM" "$CHANNEL" "$MESSAGE" "$SILENT"
exit $?
