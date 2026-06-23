# Winyle — context for Claude Code

## Your task (do this first)
Publish this folder to GitHub under the account **jacekrzepny3@gmail.com**
(GitHub username appears to be **JaRze07** — verify with `gh api user`).

1. Make sure `gh` is authenticated: `gh auth status` (if not, `gh auth login`).
2. Create a **new public repo named `winyle`**, commit everything here, push to `main`:
   ```bash
   gh repo create winyle --public --source=. --remote=origin --push
   ```
   (or do it manually with `git init && git add . && git commit -m "Winyle" && git branch -M main && git remote add origin https://github.com/<user>/winyle.git && git push -u origin main`)
3. Enable **GitHub Pages** on `main` / root so it serves over HTTPS:
   ```bash
   gh api -X POST repos/<user>/winyle/pages -f source.branch=main -f source.path=/
   ```
4. Report back the live URL (`https://<user>.github.io/winyle/`).

Do **not** commit any secrets/tokens.

## What this project is
A vinyl-collection cataloguing **PWA** (Polish UI). You pack records into boxes;
the app remembers which box and which slot each record is in so it can be found
again. It's a static site — no build step. `index.html` contains the entire app
(markup + CSS + JS + storage). Built as a gift; will likely become a native
Android app later.

## File map
- `index.html` — the whole app (UI, logic, storage layer)
- `manifest.json`, `sw.js`, `icon-192.png`, `icon-512.png` — PWA (installable, offline shell)
- `schema.sql` — Supabase/Postgres table for the optional online database
- `README.md` — full setup/deploy notes (Supabase, Claude proxy, push, install)

## How the app works (so you can maintain it)
- **Storage** is a key/value layer. `sget/sset` write to `localStorage` and also
  mirror to **Supabase** REST when `CONFIG` (top of the `<script>`) is filled in.
  Keys: `winyle-meta` (all crates + album metadata) and `winyle-cover-<id>`
  (base64 for photographed covers). API-fetched covers are stored as URL strings
  inside the metadata.
- **Data model:** `crate { id, name, closed }`;
  `album { id, crateId, position, artist, title, genre, mood, year, cover }`.
  `position` = physical slot counted **from the back** (1 = first one in = back).
  Lists always render back → front. There is intentionally no front/back toggle.
- **Add a record — 3 tiers:**
  1. **Barcode** — `BarcodeDetector` camera scan → MusicBrainz barcode lookup;
     fills artist/title/year/cover, instant ✓/✗.
  2. **Znajdź album** — iTunes + MusicBrainz/CoverArtArchive search; fills
     cover/year/genre. Upgradable to a Claude lookup if `CONFIG.CLAUDE_PROXY` is set.
  3. **Manual** — type fields + photograph the sleeve.
- **Boxes** show the cover of the most recently added (front) record.
- **Genre/mood filters** are derived from the records actually in the collection,
  not a fixed list.
- **"Słuchaj"** is a one-record-at-a-time carousel (swipe left/right, one step per
  swipe), filtered by genre/mood, that shows the box + slot to go dig out.

## Config (client-side, in `index.html` → `CONFIG`)
- `SUPABASE_URL` + `SUPABASE_KEY` (anon public key) → online sync. Run `schema.sql`
  in the Supabase SQL editor first. Empty = on-device only.
- `CLAUDE_PROXY` → optional; URL of a server endpoint holding an Anthropic API key
  (see README for a Cloudflare Worker example). The key must not be in the browser.

## Constraints
- Barcode camera + PWA install require **HTTPS** → GitHub Pages covers it.
- Single-file app by design; keep it that way unless asked to refactor.

## Possible follow-ups (only if asked)
- Deploy the Claude proxy and set `CLAUDE_PROXY`.
- Wire up a Supabase project end-to-end.
- Build a native Android version (Kotlin/Compose + Room + sync).
