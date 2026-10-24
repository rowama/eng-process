"""MCP protocol driver (layer 3) for agent-facing tools, using the official `mcp` SDK over stdio.
Each DSL call maps to one tool call on the server under test. Freely editable."""
import asyncio
import json
import shlex


class McpDriver:
    def __init__(self, command):
        self.argv = shlex.split(command)

    def _call(self, tool, **args):
        from mcp import ClientSession, StdioServerParameters
        from mcp.client.stdio import stdio_client

        async def run():
            params = StdioServerParameters(command=self.argv[0], args=self.argv[1:])
            async with stdio_client(params) as (r, w):
                async with ClientSession(r, w) as s:
                    await s.initialize()
                    res = await s.call_tool(tool, args)
                    text = "".join(getattr(c, "text", "") for c in res.content)
                    return json.loads(text) if text.strip().startswith(("[", "{")) else text
        return asyncio.run(run())

    def register_user(self, name):
        self._call("register_user", name=name)

    def add_product(self, name, price):
        self._call("add_product", name=name, price=price)

    def place_order(self, user, product, quantity):
        self._call("place_order", user=user, product=product, quantity=quantity)

    def orders_for(self, user):
        return self._call("list_orders", user=user)

    def close(self):
        pass
