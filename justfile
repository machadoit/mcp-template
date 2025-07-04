# Build the Docker image
build:
    docker build -t mcp-template .

# Test with MCP Inspector
test: build
    npx @modelcontextprotocol/inspector docker run -i --rm \
        --network none \
        --user $(id -u):$(id -g) \
        --read-only \
        --tmpfs /tmp \
        --cap-drop ALL \
        --security-opt no-new-privileges \
        mcp-template

# Interactive shell for development/debugging
dev: build
    docker run -it --rm \
        --network none \
        --user $(id -u):$(id -g) \
        --read-only \
        --tmpfs /tmp \
        --cap-drop ALL \
        --security-opt no-new-privileges \
        --entrypoint /bin/sh \
        mcp-template

# Run the actual MCP server (configration that you could use in the mcp settings of an agent)
serve: build
    docker run -i -d --rm \
        --network none \
        --user $(id -u):$(id -g) \
        --read-only \
        --tmpfs /tmp \
        --cap-drop ALL \
        --security-opt no-new-privileges \
        mcp-template
