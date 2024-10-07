from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
import httpx
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()
app = FastAPI()
BASE_URL = os.getenv("BASE_URL")
TOKEN = os.getenv("TOKEN")

# Set up CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust this to specify allowed origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS", "HEAD"])
async def proxy(request: Request, path: str):
    url = f"{BASE_URL}/{path}"
    query_params = request.query_params
    if query_params:
        url = f"{url}?{query_params}"
    method = request.method
    headers = {
        'X-Token': TOKEN,
        'accept': 'application/json',
    }

    async with httpx.AsyncClient() as client:
        response = await client.request(method, url, headers=headers)

    return Response(content=response.content, status_code=response.status_code, headers=dict(response.headers))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="localhost", port=8000)