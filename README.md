# Gemini CLI Docker

Run [Google Gemini CLI](https://github.com/google-gemini/gemini-cli) in a Docker container. Gemini CLI is an open-source AI agent that brings the power of Gemini directly into your terminal with access to Gemini 2.5 Pro and a 1M token context window.

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
- [Google API key](https://aistudio.google.com/apikey) (free) or Google account

## Usage Examples

### Basic Interactive Session

```bash
# Start an interactive Gemini CLI session
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

### One-Shot Commands

```bash
# Ask a question about your codebase
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini "explain the architecture of this project"

# Generate code
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini "create a REST API endpoint for user authentication"

# Fix bugs
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini "fix the failing tests in src/utils"

# Code review
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini "review the changes in the last commit for security issues"

# Generate documentation
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini "generate API documentation for this module"
```

### With Full Configuration (Recommended)

```bash
# Full setup with persistent config, git, and SSH
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
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

# One-shot command
docker compose run --rm gemini gemini "explain this code"
```

### Sandbox Mode

```bash
# Run in sandbox mode for safer execution
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini --sandbox "refactor this code"
```

### With Google Search Grounding

Gemini CLI has built-in Google Search for up-to-date information:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini "what are the latest best practices for React 19?"
```

## Sharing Your Gemini Configuration

The `~/.gemini` directory contains your Gemini CLI configuration, themes, and settings.

### What's in ~/.gemini

```
~/.gemini/
├── settings.json         # Global settings and preferences
├── GEMINI.md             # Custom instructions (like CLAUDE.md)
└── themes/               # Custom color themes
```

### Mount Your Configuration

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

## Authentication

### Option 1: API Key (Recommended for Docker)

Get a free API key from [Google AI Studio](https://aistudio.google.com/apikey):

```bash
-e GOOGLE_API_KEY=AI...
```

**Free tier includes:**
- 60 requests per minute
- 1,000 requests per day
- Access to Gemini 2.5 Pro with 1M token context

### Option 2: Google Account Login

For browser-based authentication:

**Step 1: Login (once)**

```bash
# Login with Google account (requires host network for callback)
docker run -it --rm \
  --network host \
  -v ~/.gemini:/home/coder/.gemini \
  ungb/gemini-cli
```

Follow the prompts to authenticate with your Google account.

**Step 2: Use normally**

```bash
# Now run without API key - auth is in ~/.gemini
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  ungb/gemini-cli
```

> **Note**: Mount `~/.gemini` from your host so auth persists between container runs.

### Option 3: Vertex AI (Enterprise)

For Google Cloud users:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.config/gcloud:/home/coder/.config/gcloud:ro \
  -e GOOGLE_CLOUD_PROJECT=your-project \
  -e GOOGLE_CLOUD_REGION=us-central1 \
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

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GOOGLE_API_KEY` | Yes* | Google AI Studio API key |
| `GOOGLE_CLOUD_PROJECT` | No | GCP project ID (for Vertex AI) |
| `GOOGLE_CLOUD_REGION` | No | GCP region (for Vertex AI) |
| `GEMINI_MODEL` | No | Model to use (default: gemini-2.5-pro) |

*Required unless using Google account login or Vertex AI

## Built-in Tools

Gemini CLI includes these tools out of the box:
- **Google Search** - Grounded answers with web search
- **File Operations** - Read, write, edit files
- **Shell Commands** - Execute terminal commands
- **Web Fetch** - Retrieve web content

## Utility Commands

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

## Building Locally

```bash
git clone https://github.com/ungb/gemini-cli-docker.git
cd gemini-cli-docker
docker build -t gemini-cli .
```

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

## Shell Alias (Convenience)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias gemini-docker='docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.gemini:/home/coder/.gemini \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli gemini'

# Usage: gemini-docker "explain this code"
```

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [Gemini CLI Documentation](https://geminicli.com/)
- [Gemini CLI GitHub](https://github.com/google-gemini/gemini-cli)
- [Google AI Studio](https://aistudio.google.com/)
- [Get API Key](https://aistudio.google.com/apikey)
