# Aluminum Dog Mods

Public download source for [aluminum-dog-games-site](https://github.com/masonghg/aluminum-dog-games-site).

The website loads `manifest.json` and the zip/media files from **this** repo. Cursor agents working on Noita / FTL / Soulforge should publish **here only** — no website branch or PR required.

## Slots

| ID | File |
| --- | --- |
| `noita-multiplayer` | `noita-multiplayer.zip` |
| `ftl-multiplayer` | `ftl-multiplayer.zip` |
| `soulforge-multiplayer` | `soulforge-multiplayer.zip` |

## Publish a build (cheapest for Cursor)

```bash
./scripts/publish-mod.sh soulforge-multiplayer /path/to/mod.zip 1.4.2 "What changed"
git add -A
git commit -m "Publish soulforge-multiplayer 1.4.2"
git push
```

Or fire-and-forget from another repo (needs a PAT with `contents: write` on this repo):

```bash
gh api repos/masonghg/aluminum-dog-mods/dispatches \
  -f event_type=publish-mod \
  -f client_payload[mod_id]=soulforge-multiplayer \
  -f client_payload[version]=1.4.2 \
  -f client_payload[download_url]="https://.../mod.zip" \
  -f client_payload[changelog]="Sync fixes"
```

Friends always use the same site download buttons; they pick up the new zip automatically after GitHub finishes the push.
