# Build the Docker image
build:
    docker build -t mcp-template .

# Run container in background
run: build
    docker run -i -d --rm mcp-template

# Test with MCP Inspector (runs a new container)
test: build
    npx @modelcontextprotocol/inspector docker run -i --rm mcp-template
