#Example file from https://github.com/jlowin/fastmcp
from fastmcp import FastMCP
import os

mcp = FastMCP("Demo 🚀")

@mcp.tool
def add(a: int, b: int) -> int:
    """Add two numbers"""
    return a + b

@mcp.tool
def list_files(path: str = ".") -> list[str]:
    """List files and folders in the given path"""
    return os.listdir(path)

if __name__ == "__main__":
    mcp.run()
