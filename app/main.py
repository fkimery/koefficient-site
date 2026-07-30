import os

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

app = FastAPI(title="Koefficient Site")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
templates = Jinja2Templates(directory=os.path.join(BASE_DIR, "templates"))
app.mount("/static", StaticFiles(directory=os.path.join(BASE_DIR, "static")), name="static")


@app.get("/")
async def home(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})


@app.get("/health")
async def health():
    """Railway health check endpoint."""
    return JSONResponse({"status": "ok"})


# ---- API stubs: these grow into the real thing ----
# /api/videos      -> list videos from DB (YouTube sync job fills the table)
# /api/videos?tag= -> tag filtering
# /api/live        -> current Twitch live status (fed by EventSub webhook)
# /api/schedule    -> stream schedule


@app.get("/api/live")
async def live_status():
    # TODO: read from DB once Twitch EventSub is wired up
    return {"live": False, "title": None, "category": None}


@app.get("/api/videos")
async def list_videos(tag: str = None):
    # TODO: read from DB once YouTube sync exists
    return {"videos": [], "tag": tag}
