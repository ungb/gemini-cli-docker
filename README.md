# Gemini CLI Docker

Run [Google Gemini CLI](https://github.com/google-gemini/gemini-cli) in a Docker container. Gemini CLI is an open-source AI agent that brings the power of Gemini directly into your terminal with access to Gemini 2.5 Pro and a 1M token context window.

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Authentication](#authentication)
  - [API Key (Recommended for Docker)](#api-key-recommended-for-docker)
  - [Google Account Login](#google-account-login)
  - [Vertex AI (Enterprise)](#vertex-ai-enterprise)
- [Usage Examples](#usage-examples)
  - [Interactive Session](#interactive-session)
  - [One-Shot Commands (Non-Interactive)](#one-shot-commands-non-interactive)
  - [Full Configuration (Recommended)](#full-configuration-recommended)
  - [Using Docker Compose](#using-docker-compose)
  - [YOLO Mode](#yolo-mode)
  - [Sandbox Mode](#sandbox-mode)
  - [With Google Search Grounding](#with-google-search-grounding)
- [Configuration](#configuration)
  - [Sharing Your Gemini Configuration](#sharing-your-gemini-configuration)
  - [Custom Instructions with GEMINI.md](#custom-instructions-with-geminimd)
  - [Project-Specific GEMINI.md](#project-specific-geminimd)
- [Volume Mounts](#volume-mounts)
- [Working with External Files and Screenshots](#working-with-external-files-and-screenshots)
- [Environment Variables](#environment-variables)
- [Built-in Tools](#built-in-tools)
- [MCP (Model Context Protocol) Support](#mcp-model-context-protocol-support)
- [Troubleshooting](#troubleshooting)
- [Shell Alias (Convenience)](#shell-alias-convenience)
- [Building Locally](#building-locally)
- [License](#license)
- [Links](#links)

## Quick Start

```bash
# Pull and run (replace with your API key)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=your-key \
  ungb/gemini-cli
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) installed
- One of the following:
  - [Google API key](https://aistudio.google.com/apikey) (free tier available)
  - Google account for OAuth login
  - Google Cloud account for Vertex AI

## Authentication

Choose your authentication method:

| Plan Type | Authentication Method | Section |
|-----------|----------------------|---------|
| **Free/Personal Use** | API Key (recommended) | [API Key Setup](#api-key-recommended-for-docker) |
| **Google Account** | OAuth Login | [Google Account Login](#google-account-login) |
| **Enterprise (GCP)** | Vertex AI | [Vertex AI Setup](#vertex-ai-enterprise) |

### API Key (Recommended for Docker)

Get a free API key from [Google AI Studio](https://aistudio.google.com/apikey):

```bash
# Set your API key as an environment variable
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=AI... \
  ungb/gemini-cli
```

Or use an environment variable from your shell:

```bash
# Export once in your shell
export GOOGLE_API_KEY=AI...

# Then use in docker commands
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

**Free tier includes:**
- 60 requests per minute
- 1,000 requests per day
- Access to Gemini 2.5 Pro with 1M token context

### Google Account Login

For browser-based authentication:

#### One-Time Setup

```bash
# Login with Google account (requires host network for callback)
docker run -it --rm \
  --network host \
  -v ~/.gemini:/home/coder/.gemini \
  ungb/gemini-cli
```

Follow the prompts to authenticate with your Google account.

#### Daily Usage

After the one-time login, simply run:

```bash
# No API key needed!
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  ungb/gemini-cli
```

> **Important**: Always mount `-v ~/.gemini:/home/coder/.gemini` to persist your login. Without this mount, you'll need to login every time.

### Vertex AI (Enterprise)

For Google Cloud users:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.config/gcloud:/home/coder/.config/gcloud:ro \
  -e GOOGLE_CLOUD_PROJECT=your-project \
  -e GOOGLE_CLOUD_REGION=us-central1 \
  ungb/gemini-cli
```

## Usage Examples

### Interactive Session

```bash
# Start an interactive Gemini CLI session
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

### One-Shot Commands (Non-Interactive)

Use the `-p` (or `--prompt`) flag for non-interactive mode:

```bash
# Ask a question about your codebase
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini -p "explain the architecture of this project"

# Generate code
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini -p "create a REST API endpoint for user authentication"

# Code review
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini -p "review the changes in the last commit for security issues"

# JSON output (for scripts/automation)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini -p --output-format json "list all TODO comments"
```

> **Note**: Non-interactive mode (`-p`) has limitations - it cannot authorize tools like WriteFile or run shell commands. For tasks requiring file modifications, use interactive mode.

### Full Configuration (Recommended)

```bash
# Full setup with persistent config, git, SSH, and screenshots
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -v ~/gemini-screenshots:/screenshots \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

### Using Docker Compose

1. Copy `docker-compose.yml` to your project:

```bash
curl -O https://raw.githubusercontent.com/ungb/gemini-cli-docker/main/docker-compose.yml
```

2. Create a `.env` file:

```bash
echo "GOOGLE_API_KEY=your-key-here" > .env
```

3. Run:

```bash
# Interactive session
docker compose run --rm gemini

# One-shot command (non-interactive, read-only)
docker compose run --rm gemini gemini -p "explain this code"
```

### YOLO Mode

```bash
# Auto-approve all tool calls (use with caution)
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini --yolo "refactor this code"
```

### Sandbox Mode

```bash
# Run in sandbox mode for safer execution
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini --sandbox "analyze this code"
```

### With Google Search Grounding

Gemini CLI has built-in Google Search for up-to-date information (works in interactive mode):

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli

# Then ask: "what are the latest best practices for React 19?"
```

## Configuration

### Sharing Your Gemini Configuration

The `~/.gemini` directory contains your Gemini CLI configuration, themes, and settings.

#### What's in ~/.gemini

```
~/.gemini/
├── settings.json         # Global settings and preferences
├── GEMINI.md             # Custom instructions (like CLAUDE.md)
└── themes/               # Custom color themes
```

#### Mount Your Configuration

```bash
# Share your Gemini config folder
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

### Custom Instructions with GEMINI.md

Create `~/.gemini/GEMINI.md` (or `GEMINI.md` in your project root) with instructions:

```markdown
# Project Instructions

- Use TypeScript with strict mode
- Follow the existing code patterns
- Add tests for new functionality
```

The file is automatically picked up when mounted:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

### Project-Specific GEMINI.md

Your project can have its own `GEMINI.md` at the root:

```bash
# Project's GEMINI.md is automatically available at /workspace/GEMINI.md
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

## Volume Mounts

| Mount | Purpose |
|-------|---------|
| `/workspace` | Your project directory (required) |
| `/home/coder/.gemini` | Gemini config, themes, settings |
| `/home/coder/.ssh` | SSH keys for git operations (read-only) |
| `/home/coder/.gitconfig` | Git configuration (read-only) |
| `/home/coder/.config/gcloud` | Google Cloud credentials for Vertex AI |
| `/screenshots` | Optional: Dedicated folder for screenshots and images (recommended) |

## Working with External Files and Screenshots

**Important**: Drag-and-drop doesn't work when Gemini CLI runs in a Docker container because it's isolated from your host filesystem. You need to explicitly mount directories to make files accessible.

### Recommended Setup: Dedicated Screenshots Folder

Create a dedicated folder on your host machine for screenshots and images you want to share with Gemini CLI:

#### Step 1: Create the Screenshots Directory

```bash
# Create a dedicated screenshots folder
mkdir -p ~/gemini-screenshots
```

#### Step 2: Mount the Screenshots Folder

**Using docker run:**

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -v ~/gemini-screenshots:/screenshots \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

**Using docker-compose:**

Update your `docker-compose.yml` to include the screenshots mount:

```yaml
volumes:
  - ./:/workspace
  - ~/.gemini:/home/coder/.gemini
  - ~/gemini-screenshots:/screenshots  # Add this line
```

#### Step 3: Add Your Files

```bash
# Copy screenshots or images to the folder
cp ~/Downloads/screenshot.png ~/gemini-screenshots/
cp ~/Desktop/diagram.jpg ~/gemini-screenshots/

# Or save screenshots directly to this folder using your screenshot tool
```

#### Step 4: Reference Files in Gemini CLI

Inside Gemini CLI, reference files using the mounted path:

```
Can you analyze /screenshots/screenshot.png?
```

```
Please review the UI in /screenshots/mockup.png and suggest improvements
```

```
Read the diagram at /screenshots/architecture.jpg and explain the flow
```

### Alternative: Using Your Downloads Folder

You can also mount your Downloads folder directly:

```bash
# Mount Downloads folder (read-only recommended for safety)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -v ~/Downloads:/downloads:ro \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

Then reference files:

```
Analyze /downloads/screenshot.png
```

### Alternative: Copy Files to Your Workspace

If you're working on a specific project, copy files directly into your project directory:

```bash
# Copy to your project directory (which is already mounted as /workspace)
cp ~/Downloads/screenshot.png /path/to/your/project/

# Then in Gemini CLI:
# Analyze /workspace/screenshot.png
```

### Multiple Mount Points Example

You can mount multiple directories for different purposes:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -v ~/gemini-screenshots:/screenshots \
  -v ~/Downloads:/downloads:ro \
  -v ~/Documents:/docs:ro \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

This gives you access to:
- `/workspace` - Your current project
- `/screenshots` - Dedicated screenshots folder (read-write)
- `/downloads` - Downloads folder (read-only)
- `/docs` - Documents folder (read-only)

### Tips for Working with External Files

1. **Use descriptive paths**: Instead of `screenshot.png`, use `login-page-error.png`
2. **Organize by purpose**: Create subfolders in `~/gemini-screenshots/` like `bugs/`, `designs/`, `diagrams/`
3. **Read-only mounts**: Use `:ro` flag for folders you only need to read from (safety measure)
4. **Absolute paths**: Always use absolute paths when referencing files (e.g., `/screenshots/image.png`)

### Example Workflow

```bash
# 1. Take a screenshot (macOS example)
# Press Cmd+Shift+4 and save to ~/gemini-screenshots/

# 2. Start Gemini CLI with screenshots mounted
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -v ~/gemini-screenshots:/screenshots \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli

# 3. In Gemini CLI, reference the screenshot
> Can you analyze the error message in /screenshots/error-screenshot.png and help me fix it?
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GOOGLE_API_KEY` | Conditional* | Google AI Studio API key |
| `GOOGLE_CLOUD_PROJECT` | No | GCP project ID (for Vertex AI) |
| `GOOGLE_CLOUD_REGION` | No | GCP region (for Vertex AI) |
| `GEMINI_MODEL` | No | Model to use (default: gemini-2.5-pro) |

*Required unless using Google account login or Vertex AI.

## Built-in Tools

Gemini CLI includes these tools out of the box:
- **Google Search** - Grounded answers with web search
- **File Operations** - Read, write, edit files
- **Shell Commands** - Execute terminal commands
- **Web Fetch** - Retrieve web content

## MCP (Model Context Protocol) Support

> **Warning**: MCP support in Docker containers is limited and may require additional configuration.

### Current Limitations

Gemini CLI supports MCP, but in Docker:

1. **Stdio-based MCP servers** need the server binary installed inside the container
2. **Network-based MCP servers** need proper network configuration
3. **MCP servers that access local resources** need those resources mounted
4. **Authentication** for MCP servers may not transfer into the container

### What Might Work

| MCP Type | Status | Notes |
|----------|--------|-------|
| HTTP/SSE servers (remote) | May work | Requires `--network host` or port mapping |
| Stdio servers (local) | Unlikely | Server must be installed in container |
| Servers needing local files | Partial | Files must be mounted |
| Servers with OAuth | Unlikely | Auth flow may not complete |

### Attempting MCP with Docker

```bash
# Mount MCP config and use host network
docker run -it --rm \
  --network host \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

### Building a Custom Image with MCP Servers

```dockerfile
FROM ungb/gemini-cli:latest

USER root
RUN npm install -g @anthropic/mcp-server-filesystem
USER coder
```

### MCP Investigation Needed

Full MCP support requires further investigation. Gemini CLI's MCP implementation may differ from Claude Code. If you have solutions, please open an issue or PR!

## Troubleshooting

### Permission Denied on Mounted Files

```bash
# Run with your user ID
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

### Git Operations Failing

Ensure SSH keys are mounted and git is configured:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

### API Key Invalid

Verify your API key works:

```bash
curl -H "x-goog-api-key: $GOOGLE_API_KEY" \
  "https://generativelanguage.googleapis.com/v1beta/models"
```

### Rate Limits

Free tier limits: 60 requests/minute, 1,000 requests/day. For higher limits:
- Use multiple API keys
- Upgrade to Vertex AI
- Use a paid AI Studio plan

### Utility Commands

```bash
# Check version
docker run --rm ungb/gemini-cli gemini --version

# Show help
docker run --rm ungb/gemini-cli gemini --help

# Use a specific model
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  -e GEMINI_MODEL=gemini-2.0-flash \
  ungb/gemini-cli
```

## Shell Alias (Convenience)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias gemini-docker='docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -v ~/gemini-screenshots:/screenshots \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli gemini'

# Usage (interactive): gemini-docker
# Usage (one-shot):    gemini-docker -p "explain this code"
# Usage (with screenshot): gemini-docker -p "analyze /screenshots/bug.png"
```

## Building Locally

```bash
git clone https://github.com/ungb/gemini-cli-docker.git
cd gemini-cli-docker
docker build -t gemini-cli .
```

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [Gemini CLI Documentation](https://geminicli.com/)
- [Gemini CLI GitHub](https://github.com/google-gemini/gemini-cli)
- [Google AI Studio](https://aistudio.google.com/)
- [Get API Key](https://aistudio.google.com/apikey)
