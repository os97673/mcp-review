Take your previous response (the last message you sent) and pass it as-is to the `review` tool from the `mcp-review` MCP server. Use an appropriate `filename_hint` based on the content type (e.g. `plan.md` for plans, `code.py` for Python code, `analysis.md` for analysis).

After the tool returns, examine the content for lines matching `# TODO:` (case-insensitive). If any are found, acknowledge each one, revise the content to address them, remove the TODO lines, and call `review` again with the revised content. Repeat until no TODOs remain, then present the final approved content.
