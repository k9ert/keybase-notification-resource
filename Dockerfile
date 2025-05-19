FROM alpine:3.16

# Install dependencies
RUN apk add --no-cache \
    bash \
    ca-certificates \
    jq \
    curl

# Create resource directory
RUN mkdir -p /opt/resource

# Copy resource scripts
COPY check /opt/resource/
COPY in /opt/resource/
COPY out /opt/resource/
COPY keybase_sender.sh /opt/resource/

# Make scripts executable
RUN chmod +x /opt/resource/check /opt/resource/in /opt/resource/out /opt/resource/keybase_sender.sh

# Set working directory
WORKDIR /opt/resource
