# Gemini CLI Docker

Run [Google Gemini CLI](https://github.com/google-gemini/gemini-cli) in a Docker container. Gemini CLI is an open-source AI agent that brings the power of Gemini directly into your terminal.

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

## Usage

### Using Docker Run

```bash
# Basic usage with API key
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli

# With persistent config (remembers settings between runs)
docker run -it --rm \
  -v $(pwd):/workspace \
  -v gemini-config:/home/coder/.gemini \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli

# With git/ssh support
docker run -it --rm \
  -v $(pwd):/workspace \
  -v gemini-config:/home/coder/.gemini \
  -v ~/.ssh:/home/coder/.ssh:ro \
  -v ~/.gitconfig:/home/coder/.gitconfig:ro \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli
```

### Using Docker Compose

1. Clone this repo or copy `docker-compose.yml` to your project:

```bash
curl -O https://raw.githubusercontent.com/ungb/gemini-cli-docker/main/docker-compose.yml
```

2. Create a `.env` file with your API key:

```bash
echo "GOOGLE_API_KEY=your-key-here" > .env
```

3. Run:

```bash
docker compose run --rm gemini
```

### Run a Specific Command

```bash
# Run gemini with a prompt
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  ungb/gemini-cli \
  gemini "explain this codebase"

# Check version
docker run -it --rm ungb/gemini-cli gemini --version

# Run with specific model
docker run -it --rm \
  -v $(pwd):/workspace \
  -e GOOGLE_API_KEY=$GOOGLE_API_KEY \
  -e GEMINI_MODEL=gemini-2.5-pro \
  ungb/gemini-cli
```

## Authentication

### Option 1: API Key (Recommended for Docker)

Get a free API key from [Google AI Studio](https://aistudio.google.com/apikey) and pass it as an environment variable:

```bash
-e GOOGLE_API_KEY=AI...
```

**Free tier includes:**
- 60 requests per minute
- 1,000 requests per day
- Access to Gemini 2.5 Pro with 1M token context window

### Option 2: Google Account Login

For browser-based authentication (requires host network):

```bash
docker run -it --rm \
  --network host \
  -v $(pwd):/workspace \
  -v gemini-config:/home/coder/.gemini \
  ungb/gemini-cli
```

Then follow the prompts to authenticate with your Google account.

### Option 3: Vertex AI

For enterprise users with Google Cloud:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.config/gcloud:/home/coder/.config/gcloud:ro \
  -e GOOGLE_CLOUD_PROJECT=your-project \
  ungb/gemini-cli
```

## Volume Mounts

| Mount | Purpose |
|-------|---------|
| `/workspace` | Your project directory (required) |
| `/home/coder/.gemini` | Gemini config and cache (optional, for persistence) |
| `/home/coder/.ssh` | SSH keys for git operations (optional, read-only) |
| `/home/coder/.gitconfig` | Git configuration (optional, read-only) |
| `/home/coder/.config/gcloud` | Google Cloud credentials (optional, for Vertex AI) |

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GOOGLE_API_KEY` | Yes* | Google AI Studio API key |
| `GOOGLE_CLOUD_PROJECT` | No | GCP project ID (for Vertex AI) |
| `GOOGLE_CLOUD_REGION` | No | GCP region (for Vertex AI) |
| `GEMINI_MODEL` | No | Model to use (default: gemini-2.5-pro) |

*Required unless using Google account login or Vertex AI

## Features

Gemini CLI includes built-in tools for:
- Google Search grounding
- File operations
- Shell commands
- Web fetching
- MCP (Model Context Protocol) extensions

## Building Locally

```bash
git clone https://github.com/ungb/gemini-cli-docker.git
cd gemini-cli-docker
docker build -t gemini-cli .
```

## Troubleshooting

### Permission Denied on Mounted Files

The container runs as user `coder` (UID 1000). If you have permission issues:

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

### Authentication Issues

Make sure your API key is valid:

```bash
# Test your API key
curl -H "x-goog-api-key: $GOOGLE_API_KEY" \
  "https://generativelanguage.googleapis.com/v1beta/models"
```

## License

MIT License - see [LICENSE](LICENSE)

## Links

- [Gemini CLI Documentation](https://geminicli.com/)
- [Gemini CLI GitHub](https://github.com/google-gemini/gemini-cli)
- [Google AI Studio](https://aistudio.google.com/)
- [Get API Key](https://aistudio.google.com/apikey)
