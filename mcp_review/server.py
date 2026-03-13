import os
import shlex
import subprocess
import tempfile
from pathlib import Path

import mcp.server.stdio
import mcp.types as types
from mcp.server import Server

HEADER = (
    "# Review the content below. Add '# TODO: <comment>' for anything to address.\n"
    "# Save and close the file to continue.\n\n"
)

app = Server("mcp-review")


@app.list_tools()
async def list_tools() -> list[types.Tool]:
    return [
        types.Tool(
            name="iterate",
            description=(
                "Opens content in the user's $GUI_EDITOR for review. "
                "The user may add '# TODO: <comment>' annotations. "
                "Returns the edited content as-is."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "content": {
                        "type": "string",
                        "description": "The content to present for human review",
                    },
                    "filename_hint": {
                        "type": "string",
                        "description": (
                            "Optional filename suffix for syntax highlighting "
                            "(e.g. 'plan.md', 'code.py')"
                        ),
                    },
                },
                "required": ["content"],
            },
        )
    ]


@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[types.TextContent]:
    if name != "iterate":
        raise ValueError(f"Unknown tool: {name}")

    content = arguments.get("content", "")
    hint = arguments.get("filename_hint", "review.md")

    suffix = Path(hint).suffix or ".md"

    with tempfile.NamedTemporaryFile(
        mode="w", suffix=suffix, prefix="mcp-review-", delete=False, encoding="utf-8"
    ) as f:
        f.write(HEADER + content)
        tmp_path = f.name

    try:
        editor = os.environ.get("GUI_EDITOR", "code --wait")
        cmd = shlex.split(editor) + [tmp_path]
        subprocess.run(cmd, check=True)

        edited = Path(tmp_path).read_text(encoding="utf-8")
    finally:
        Path(tmp_path).unlink(missing_ok=True)

    # Strip the header we prepended before returning to Claude
    body = edited[len(HEADER):] if edited.startswith(HEADER) else edited

    return [types.TextContent(type="text", text=body)]


async def _main() -> None:
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await app.run(read_stream, write_stream, app.create_initialization_options())


def main() -> None:
    import asyncio
    asyncio.run(_main())


if __name__ == "__main__":
    main()
