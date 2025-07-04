FROM python:3.12-slim

# Install dependencies and clean up in single layer
RUN pip install --no-cache-dir fastmcp && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create app directory for MCP server code
WORKDIR /app
COPY server.py .

# Create workdir for mounted folders
WORKDIR /workdir

ENTRYPOINT ["python", "/app/server.py"]
