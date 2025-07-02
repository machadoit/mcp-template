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

# Run container in background
just run
```

### Manual Usage (without Just)

```bash
# Build
docker build -t mcp-template .

# Test with Inspector
npx @modelcontextprotocol/inspector docker run -i --rm mcp-template

# Run in background
docker run -i -d --rm --name=mcp-template mcp-template
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
def greet(name: str) -> str:
    """Greet someone by name"""
    return f"Hello, {name}!"

@mcp.tool
def list_files() -> str:
    """List files in current directory"""
    import os
    return "\n".join(os.listdir("."))
```

## Security & Access Control

This template emphasizes **secure, controlled access** to your file system:

### Sandboxed Execution
- **Container isolation** - MCP server runs in its own container environment
- **Controlled network access** - Add `--network none` to disable internet, or allow selective connectivity

### Controlled File Access
By default, the container has **no access** to your host files. You explicitly grant access using volume mounts:

```bash
# Read-only access to specific directories
docker run -i --rm -v $HOME/my-docs:/workdir/docs:ro mcp-template
docker run -i --rm -v $HOME/code:/workdir/code:ro mcp-template

# Read-write access
docker run -i --rm -v $HOME/sandbox:/workdir/sandbox:rw mcp-template
```

### Why This Matters
- **Prevent accidents** - MCP server can't modify files unless explicitly permitted
- **Limit scope** - Only mount directories the server actually needs
- **Audit access** - Clear visibility into what directories are accessible
- **Safe experimentation** - Test tools on copies/sandboxes before using on real data

This approach lets you build powerful MCP tools while maintaining **fine-grained control** over what they can access.

## Configuration

### Connecting to Claude Desktop

To use this MCP server with Claude Desktop, add it to your `claude_desktop_config.json` configuration file:

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

#### To add read access to your Documents you can:

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
