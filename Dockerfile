FROM python:3.12-slim

RUN pip install --no-cache-dir fastmcp

# Create app directory for MCP server code
WORKDIR /app
COPY server.py .

# Create workdir for mounted folders
WORKDIR /workdir

ENTRYPOINT ["python", "/app/server.py"]
