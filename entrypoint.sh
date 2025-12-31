#!/bin/bash
set -e

# Initialize Gemini configuration directory if needed
if [ ! -d "$HOME/.gemini" ]; then
    mkdir -p "$HOME/.gemini"
fi

# Fix SSH permissions if mounted
if [ -d "$HOME/.ssh" ]; then
    # Create a writable copy if needed for known_hosts
    if [ ! -w "$HOME/.ssh" ]; then
        mkdir -p "$HOME/.ssh-local"
        cp -r "$HOME/.ssh/"* "$HOME/.ssh-local/" 2>/dev/null || true
        export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=$HOME/.ssh-local/known_hosts -i $HOME/.ssh/id_rsa -i $HOME/.ssh/id_ed25519 2>/dev/null"
    fi
fi

# Configure git to use safe directory for mounted volumes
git config --global --add safe.directory /workspace 2>/dev/null || true

# Display helpful info on first run
if [ ! -f "$HOME/.gemini/.initialized" ]; then
    echo "=================================="
    echo "  Gemini CLI Docker Container"
    echo "=================================="
    echo ""
    echo "Workspace: /workspace"
    echo "Config:    $HOME/.gemini"
    echo ""
    if [ -z "$GOOGLE_API_KEY" ]; then
        echo "Note: GOOGLE_API_KEY not set"
        echo "Run with: -e GOOGLE_API_KEY=your-key"
        echo ""
        echo "Get a free API key at:"
        echo "  https://aistudio.google.com/apikey"
        echo ""
        echo "Or login with Google account:"
        echo "  gemini (and follow prompts)"
    else
        echo "API Key: configured"
    fi
    echo ""
    touch "$HOME/.gemini/.initialized"
fi

# Execute the command
exec "$@"
