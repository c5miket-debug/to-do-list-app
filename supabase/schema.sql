-- =============================================================================
-- INFERRED SCHEMA — derived from application code in index.html.
-- NOT a live dump of the production database.
-- Replace this file with a real dump after restore (see supabase/RESTORE.md).
-- =============================================================================
--
-- Unknowns (not visible from the client; confirm against the live project):
--   * Whether tasks.category_id has a foreign key to categories(id)
--   * ON DELETE behavior if that FK exists
--       (the client nulls category_id locally on category delete, but does
--        not UPDATE tasks in the database)
--   * Column defaults (created_at, updated_at, done, pinned, priority)
--   * Whether user_id has a DB default or trigger from auth.uid()
--   * Exact type of user_settings.tickers (text[] vs jsonb — client stores
--     a JS array of ticker symbols)
--
-- Priority: the UI labels P1–P4, but JS stores integers 1–4
--   (sorts with `a.priority - b.priority`, default 4, parseInt on import).
-- =============================================================================

create extension if not exists "pgcrypto";

-- categories
create table if not exists public.categories (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  user_id    uuid not null,          -- auth user
  created_at timestamptz default now()
);

-- tasks
create table if not exists public.tasks (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  category_id uuid,                  -- nullable; FK unknown (see header)
  priority    int not null,          -- 1–4 (P1–P4 in the UI)
  due_date    text,                  -- nullable, YYYY-MM-DD
  due_time    text,                  -- nullable
  recur       text,                  -- nullable: daily|weekly|biweekly|monthly|yearly
  notes       text,                  -- nullable
  pinned      boolean,
  done        boolean,
  subtasks    jsonb,                 -- array of { title, done }
  user_id     uuid not null,
  created_at  timestamptz default now()
);

-- user_settings (client upserts onConflict: user_id)
create table if not exists public.user_settings (
  user_id    uuid primary key,
  tickers    text[],                 -- or jsonb; client stores an array of symbols
  theme      text,                   -- 'light' | 'dark' | 'device'
  updated_at timestamptz
);

-- -----------------------------------------------------------------------------
-- Recommended RLS (enable + owner policies). Apply if missing after resume.
-- -----------------------------------------------------------------------------

alter table public.categories enable row level security;
alter table public.tasks enable row level security;
alter table public.user_settings enable row level security;

-- categories
create policy "categories_select_own" on public.categories
  for select using (auth.uid() = user_id);
create policy "categories_insert_own" on public.categories
  for insert with check (auth.uid() = user_id);
create policy "categories_update_own" on public.categories
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "categories_delete_own" on public.categories
  for delete using (auth.uid() = user_id);

-- tasks
create policy "tasks_select_own" on public.tasks
  for select using (auth.uid() = user_id);
create policy "tasks_insert_own" on public.tasks
  for insert with check (auth.uid() = user_id);
create policy "tasks_update_own" on public.tasks
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "tasks_delete_own" on public.tasks
  for delete using (auth.uid() = user_id);

-- user_settings
create policy "user_settings_select_own" on public.user_settings
  for select using (auth.uid() = user_id);
create policy "user_settings_insert_own" on public.user_settings
  for insert with check (auth.uid() = user_id);
create policy "user_settings_update_own" on public.user_settings
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "user_settings_delete_own" on public.user_settings
  for delete using (auth.uid() = user_id);
