# Restore TaskFlow Supabase

The live project is **vjrxzxypctkecfzlwnjs**
(`https://vjrxzxypctkecfzlwnjs.supabase.co`).

`schema.sql` in this folder is **inferred from application code**, not a live dump. Replace it after restore.

## 1. Resume the project

The project has **already been resumed**. Confirm it is still healthy:

1. Open [https://supabase.com/dashboard](https://supabase.com/dashboard).
2. Open project `vjrxzxypctkecfzlwnjs`.
3. If it is paused again, click **Resume**. Free-tier projects can be resumed for up to **1 year** after pause.
4. Wait until the project is healthy (API + Auth responding).

## 2. Confirm Auth Site URL

1. Dashboard → **Authentication** → **URL Configuration**.
2. Confirm **Site URL** includes:

   `https://to-do-list-app-eosin-mu.vercel.app`

   Add it if missing (redirects after Google / email auth depend on this).

## 3. Verify / apply RLS

1. Dashboard → **Authentication** → **Policies** (or SQL Editor).
2. Confirm RLS is enabled on `categories`, `tasks`, and `user_settings`.
3. Confirm policies restrict select/insert/update/delete to `auth.uid() = user_id`.
4. If policies are missing, apply the recommended RLS block in `schema.sql`.

## 4. Dump the real schema over the inferred file

After the project is resumed, replace the inferred file with a real dump:

```bash
# From the Supabase SQL Editor: run and save the result, or use the CLI:
supabase db dump --schema public -f supabase/schema.sql
```

Or Dashboard → **Database** → **Schema Visualizer** / SQL Editor → dump `public` DDL and overwrite `supabase/schema.sql`. Commit the real dump so this folder stops being inferred.
