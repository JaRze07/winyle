-- Winyle online database (Supabase / Postgres)
-- Run this in Supabase: Project -> SQL Editor -> New query -> paste -> Run.

create table if not exists public.kv (
  key        text primary key,
  value      jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.kv enable row level security;

-- Personal app: the anon key gets full access. Add real auth before going public.
drop policy if exists "kv read"   on public.kv;
drop policy if exists "kv insert" on public.kv;
drop policy if exists "kv update" on public.kv;
create policy "kv read"   on public.kv for select using (true);
create policy "kv insert" on public.kv for insert with check (true);
create policy "kv update" on public.kv for update using (true) with check (true);
