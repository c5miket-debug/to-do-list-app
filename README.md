# TaskFlow

Vanilla HTML PWA to-do list. Live at [https://to-do-list-app-eosin-mu.vercel.app](https://to-do-list-app-eosin-mu.vercel.app).

This repo is the source for that Vercel deploy (`index.html` + service worker). Data lives in the Supabase project `vjrxzxypctkecfzlwnjs`.

## Restore

If the free-tier database is paused:

1. Resume the project in the [Supabase dashboard](https://supabase.com/dashboard) (up to 1 year after pause). Details: [`supabase/RESTORE.md`](supabase/RESTORE.md).
2. Confirm Auth Site URL includes `https://to-do-list-app-eosin-mu.vercel.app`.
3. Verify RLS on `categories`, `tasks`, and `user_settings`.

`supabase/schema.sql` is **inferred from application code**, not a live dump. Replace it with a real dump after restore.

## GitHub Action secrets

The keepalive workflow pings the API twice a week so the free DB stays awake.

Repo → **Settings** → **Secrets and variables** → **Actions**:

| Secret | Value |
| --- | --- |
| `SUPABASE_URL` | `https://vjrxzxypctkecfzlwnjs.supabase.co` |
| `SUPABASE_ANON_KEY` | the anon key already in `index.html` (`SUPA_KEY`) |

Do not put the service-role key here. The anon key is the public client key.
