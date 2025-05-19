FROM keybaseio/client:stable

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    jq \
    expect \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create resource directory
RUN mkdir -p /opt/resource

# Copy resource scripts
COPY check /opt/resource/
COPY in /opt/resource/
COPY out /opt/resource/
COPY generate-paperkey.sh /usr/local/bin/

# Make scripts executable
RUN chmod +x /opt/resource/check /opt/resource/in /opt/resource/out /usr/local/bin/generate-paperkey.sh

# Set working directory
WORKDIR /opt/resource
