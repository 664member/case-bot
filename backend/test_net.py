import asyncio
import aiohttp

async def main():
    async with aiohttp.ClientSession() as s:
        async with s.get("https://api.telegram.org", timeout=10) as r:
            print("status:", r.status)
            print(await r.text())

asyncio.run(main())