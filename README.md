# Koefficient Site

Fan/community hub: live status, schedule, videos with tag search, playlists.
FastAPI + Postgres, deployed on Railway.

## Local development (Windows)

```powershell
# from the project root
py -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# run the dev server
uvicorn app.main:app --reload
```

Open http://127.0.0.1:8000 — the site. http://127.0.0.1:8000/docs — auto-generated API docs.

## Environment variables

Copy `.env.example` to `.env` and fill in values as integrations get built.
Production values live in Railway → service → Variables.

## Database

Schema lives in `db/schema.sql`. Run it once against the Postgres instance
(psql, TablePlus, or the Railway/Supabase SQL console all work).

## Deploy

Pushes to `main` auto-deploy via Railway's GitHub integration.
Start command and health check are configured in `railway.json`.
