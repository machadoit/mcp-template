# MCP Template - Dockerized Model Context Protocol Server

A minimal, containerized Model Context Protocol (MCP) server built with FastMCP and Docker. This serves as a clean starting point for building your own MCP servers with secure, isolated execution environments.

## Features

- 🐳 **Fully Dockerized** - No need to install dependencies locally
- 🔒 **Flexible Access Control** - Grant precise file system permissions from read-only to full write access as needed
- 🚀 **FastMCP Framework** - Simple, decorator-based tool creation
- 🔧 **Just Integration** - Modern build automation with tab completion
- 🧪 **MCP Inspector Ready** - Easy testing with browser-based tools
- ⚡ **Minimal Setup** - Get started in seconds

## Quick Start

### Prerequisites
- Docker
- [Node.js](https://nodejs.org/) (optional, for MCP Inspector)
- [Just](https://just.systems/man/en/) (optional, for build automation)

### Install Just (recommended)
```bash
# macOS
brew install just

# Other platforms: see https://github.com/casey/just?tab=readme-ov-file#installation
```

### Usage

```bash
# Build the Docker image
just build

# Test with MCP Inspector (provides URL to open in browser)
just test

# Interactive development shell
just dev

# Run MCP server in background
just serve
```

### Manual Usage (without Just)

```bash
# Build
docker build -t mcp-template .

# Test with Inspector
npx @modelcontextprotocol/inspector docker run -i --rm mcp-template

# Run in background
docker run -i -d --rm mcp-template
```

## Testing

The MCP Inspector provides a web-based interface for testing your tools:

1. Run `just test` (or the manual npx command)
2. Copy the pre-filled URL from terminal output (includes auth token)
3. Open the URL in your browser
4. Click "Connect" to connect to your server
5. Test tools in the "Tools" tab

## Project Structure

```
mcp-template/
├── Dockerfile      # Container definition
├── server.py       # MCP server implementation
├── justfile        # Build automation
└── README.md       # This file
```

## Example Tools

The server currently includes one example tool:

- **`add(a, b)`** - Adds two numbers together

## Extending the Server

Add new tools by creating functions with the `@mcp.tool` decorator:

```python
@mcp.tool
def add(a: int, b: int) -> int:
    """Add two numbers"""
    return a + b

@mcp.tool
def multiply(a: int, b: int) -> int:
    """Multiply two numbers"""
    return a * b
```

## Security & Access Control

This template emphasizes **secure, controlled access** to your file system.

### Controlled File Access
By default, the container has **no access** to your host files. You explicitly grant access using volume mounts:

```bash
# Read-only access to specific directories
docker run -i --rm -v $HOME/my-docs:/workdir/docs:ro mcp-template
docker run -i --rm -v $HOME/code:/workdir/code:ro mcp-template

# Read-write access
docker run -i --rm -v $HOME/sandbox:/workdir/sandbox:rw mcp-template
```

### Maximum Security Configuration

For the most secure setup, combine multiple flags:

```bash
docker run -i --rm \
  --network none \
  --user $(id -u):$(id -g) \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  -v $HOME/safe-folder:/workdir/data:ro \
  mcp-template
```

> Note: You may need to replace the `$(id -u):$(id -g)` and `$HOME` with the explicit values on the agent configuration.

### Security Flags Details

For enhanced security, consider adding these Docker flags:

• **`--network none`** - Completely disables network access
  - Prevents the container from making any network connections
  - Ideal for file processing tools that don't need internet access
  - Example: `docker run -i --rm --network none mcp-template`

• **`--user $(id -u):$(id -g)`** - Runs container as current user
  - Prevents root privilege escalation
  - Files created by container will have your user ownership
  - Example: `docker run -i --rm --user $(id -u):$(id -g) mcp-template`

• **`--read-only`** - Makes container filesystem read-only
  - Prevents container from modifying its own files
  - Enhances security by limiting container's ability to persist changes
  - Example: `docker run -i --rm --read-only mcp-template`

• **`--tmpfs /tmp`** - Provides temporary filesystem in memory
  - Allows container to write to /tmp without affecting host
  - Useful when combined with `--read-only`
  - Example: `docker run -i --rm --read-only --tmpfs /tmp mcp-template`

• **`--cap-drop ALL`** - Removes all Linux capabilities
  - Minimizes container privileges
  - Prevents container from performing privileged operations
  - Example: `docker run -i --rm --cap-drop ALL mcp-template`

• **`--security-opt no-new-privileges`** - Prevents privilege escalation
  - Blocks processes from gaining additional privileges
  - Added security layer against potential exploits
  - Example: `docker run -i --rm --security-opt no-new-privileges mcp-template`

### Why This Matters
- **Prevent accidents** - MCP server can't modify files unless explicitly permitted
- **Limit scope** - Only mount directories the server actually needs
- **Audit access** - Clear visibility into what directories are accessible
- **Safe experimentation** - Test tools on copies/sandboxes before using on real data
- **Defense in depth** - Multiple security layers protect against various attack vectors

This approach lets you build powerful MCP tools while maintaining **fine-grained control** over what they can access.

## Configuration

### Connecting to Claude Desktop

To use this MCP server with Claude Desktop, add it to your `claude_desktop_config.json` configuration file:

#### Basic configuration:

```json
{
  "mcpServers": {
    "mcp-template": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm", "mcp-template"
      ]
    }
  }
}
```

#### Configuration with read access to Documents:
```json
{
  "mcpServers": {
    "mcp-template": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "<REPLACE_WITH_HOME_PATH>/Documents:/workdir/docs:ro",
        "mcp-template"
      ]
    }
  }
}
```

#### Maximum security configuration (no network, minimal privileges):
```json
{
  "mcpServers": {
    "mcp-template-max-secure": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "--network", "none",
        "--user", "<REPLACE_WITH_USER>:<REPLACE_WITH_GROUP>",
        "--read-only",
        "--tmpfs", "/tmp",
        "--cap-drop", "ALL",
        "--security-opt", "no-new-privileges",
        "-v", "<REPLACE_WITH_HOME_PATH>/Documents:/workdir/docs:ro",
        "mcp-template"
      ]
    }
  }
}
```

After adding this configuration, restart Claude Desktop. The MCP server will appear as available tools that Claude can use during conversations.

## Automated Publishing (Optional)

This template includes a GitHub Action (`.github/workflows/docker-publish.yml`) that automatically publishes Docker images to **Docker Hub** when you push code.

### To Use Docker Hub Publishing:
1. Create a Docker Hub account and repository
2. Add these to your GitHub repository settings:
   - **Variable**: `DOCKERHUB_USERNAME` (your Docker Hub username)
   - **Secret**: `DOCKERHUB_TOKEN` (your Docker Hub access token)
3. Push to `main` branch or create any tag → automatic Docker image build and publish

### To Remove Automated Publishing:
If you don't want automatic Docker Hub publishing, simply delete:
```bash
rm .github/workflows/docker-publish.yml
```

## Development Workflow

1. **Edit** `server.py` with your tools
2. **Build** with `just build` 
3. **Test** with `just test`
4. **Iterate** and repeat

## Troubleshooting

### "Connection Error" in Inspector
- Ensure you're using the auth token URL provided in terminal output
- Check that the container started successfully (docker ps)

### Container Exits Immediately (check logs)

```bash
docker ps
docker logs <name>
```

### Tool Not Appearing
- Verify the `@mcp.tool` decorator is present
- Check that the function has a docstring
- Rebuild the container after changes

## License

MIT License - Feel free to use this as a starting point for your own MCP servers.

## Resources

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [FastMCP Documentation](https://github.com/jlowin/fastmcp)
- [MCP Inspector](https://github.com/modelcontextprotocol/inspector)
- [Just Command Runner](https://just.systems/)
