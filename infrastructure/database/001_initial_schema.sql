-- Initial domain schema. Supabase Auth owns authentication identities.
-- Apply through migrations after configuring the Supabase project.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  locale text not null default 'en',
  timezone text not null default 'UTC',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null check (kind in ('note', 'task', 'event', 'idea')),
  title text,
  content text not null,
  version integer not null default 1,
  client_operation_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, client_operation_id),
  unique (user_id, id)
);

create index if not exists entries_user_updated_idx
  on public.entries(user_id, updated_at desc);

create table if not exists public.tasks (
  entry_id uuid primary key,
  user_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'inbox'
    check (status in ('inbox', 'next', 'scheduled', 'waiting', 'done', 'archived')),
  due_at timestamptz,
  priority text check (priority in ('low', 'medium', 'high')),
  completed_at timestamptz,
  foreign key (user_id, entry_id)
    references public.entries(user_id, id) on delete cascade
);

create table if not exists public.tags (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  color text,
  created_at timestamptz not null default now(),
  unique (user_id, name),
  unique (user_id, id)
);

create table if not exists public.entry_tags (
  user_id uuid not null references public.profiles(id) on delete cascade,
  entry_id uuid not null,
  tag_id uuid not null,
  primary key (entry_id, tag_id),
  foreign key (user_id, entry_id)
    references public.entries(user_id, id) on delete cascade,
  foreign key (user_id, tag_id)
    references public.tags(user_id, id) on delete cascade
);

-- RLS policies and API-role permissions must be added before production use.
-- Keep service-role credentials exclusively on trusted server infrastructure.


-- Defense-in-depth policies for authenticated access. The NestJS API must still
-- enforce ownership on every operation; never expose the service-role key.
alter table public.profiles enable row level security;
alter table public.entries enable row level security;
alter table public.tasks enable row level security;
alter table public.tags enable row level security;
alter table public.entry_tags enable row level security;

create policy "profiles_select_own" on public.profiles
  for select to authenticated using (id = auth.uid());
create policy "profiles_update_own" on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

create policy "entries_own_rows" on public.entries
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "tasks_own_rows" on public.tasks
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "tags_own_rows" on public.tags
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "entry_tags_own_rows" on public.entry_tags
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
