FROM node:22-slim

LABEL maintainer="ungb"
LABEL description="Google Gemini CLI in a Docker container"
LABEL org.opencontainers.image.source="https://github.com/ungb/gemini-cli-docker"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    openssh-client \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Google Gemini CLI globally
RUN npm install -g @google/gemini-cli

# Create non-root user for security
RUN useradd -m -s /bin/bash coder \
    && mkdir -p /home/coder/.gemini \
    && chown -R coder:coder /home/coder

# Set up workspace directory
RUN mkdir -p /workspace && chown coder:coder /workspace

# Copy entrypoint script
COPY --chown=coder:coder entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER coder
WORKDIR /workspace

# Environment variables
ENV HOME=/home/coder
ENV GEMINI_CONFIG_DIR=/home/coder/.gemini

ENTRYPOINT ["/entrypoint.sh"]
CMD ["gemini"]
