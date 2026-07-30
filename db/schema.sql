-- Initial schema. Run once against your Postgres instance.
-- The site reads from these tables; sync jobs and webhooks write to them.

CREATE TABLE IF NOT EXISTS videos (
    id            TEXT PRIMARY KEY,          -- YouTube video ID
    title         TEXT NOT NULL,
    description   TEXT,
    thumbnail_url TEXT,
    published_at  TIMESTAMPTZ NOT NULL,
    duration_sec  INTEGER,
    view_count    BIGINT,
    created_at    TIMESTAMPTZ DEFAULT now(),
    updated_at    TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS playlists (
    id          TEXT PRIMARY KEY,            -- YouTube playlist ID
    title       TEXT NOT NULL,
    description TEXT,
    item_count  INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS playlist_videos (
    playlist_id TEXT REFERENCES playlists(id) ON DELETE CASCADE,
    video_id    TEXT REFERENCES videos(id) ON DELETE CASCADE,
    position    INTEGER,
    PRIMARY KEY (playlist_id, video_id)
);

CREATE TABLE IF NOT EXISTS tags (
    id   SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL               -- lowercase, e.g. 'fighting-games'
);

CREATE TABLE IF NOT EXISTS video_tags (
    video_id TEXT REFERENCES videos(id) ON DELETE CASCADE,
    tag_id   INTEGER REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (video_id, tag_id)
);

-- Single-row table holding current Twitch live state (updated by EventSub webhook)
CREATE TABLE IF NOT EXISTS live_status (
    id         INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    is_live    BOOLEAN NOT NULL DEFAULT false,
    title      TEXT,
    category   TEXT,
    started_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT now()
);
INSERT INTO live_status (id, is_live) VALUES (1, false) ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS schedule (
    id         SERIAL PRIMARY KEY,
    day_of_week SMALLINT NOT NULL,          -- 0=Mon .. 6=Sun
    start_time TIME NOT NULL,
    end_time   TIME,
    title      TEXT NOT NULL,
    notes      TEXT,
    active     BOOLEAN DEFAULT true
);

-- Full-text search over titles/descriptions (Postgres built-in, no extensions needed)
CREATE INDEX IF NOT EXISTS idx_videos_search
    ON videos USING gin(to_tsvector('english', title || ' ' || coalesce(description, '')));

CREATE INDEX IF NOT EXISTS idx_videos_published ON videos (published_at DESC);
