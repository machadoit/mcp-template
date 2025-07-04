image_name := "mcp-template"
user_id := `id -u`
group_id := `id -g`

# Build the Docker image
build:
    docker build -t {{image_name}} .

# Test with MCP Inspector
test: build
    npx @modelcontextprotocol/inspector docker run -i --rm \
        --network none \
        --user {{user_id}}:{{group_id}} \
        --read-only \
        --tmpfs /tmp \
        --cap-drop ALL \
        --security-opt no-new-privileges \
        {{image_name}}

# Interactive shell for development/debugging
dev: build
    docker run -it --rm \
        --network none \
        --user {{user_id}}:{{group_id}} \
        --read-only \
        --tmpfs /tmp \
        --cap-drop ALL \
        --security-opt no-new-privileges \
        --entrypoint /bin/sh \
        {{image_name}}

# Run the actual MCP server (configration that you could use in the mcp settings of an agent)
serve: build
    docker run -i -d --rm \
        --network none \
        --user {{user_id}}:{{group_id}} \
        --read-only \
        --tmpfs /tmp \
        --cap-drop ALL \
        --security-opt no-new-privileges \
        {{image_name}}
