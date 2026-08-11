-- Period Logs table with secure Row-Level Security (RLS)
-- Each logged period belongs to exactly one authenticated user.

create table if not exists public.period_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  start_date date not null,
  end_date date,
  flow_level text check (flow_level in ('spotting', 'light', 'medium', 'heavy')),
  pain_level int check (pain_level between 0 and 5),
  mood text,
  symptoms text[] not null default '{}',
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Index for fast per-user queries
create index if not exists period_logs_user_id_idx on public.period_logs (user_id);
create index if not exists period_logs_start_date_idx on public.period_logs (start_date desc);

-- Keep updated_at fresh on any update
create or replace function public.period_logs_set_updated_at()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists period_logs_set_updated_at_trigger on public.period_logs;
create trigger period_logs_set_updated_at_trigger
  before update on public.period_logs
  for each row execute function public.period_logs_set_updated_at();

-- Table-wide grants (matches Supabase's default public-schema grants)
grant select, insert, update, delete on public.period_logs to authenticated;
grant select, insert, update, delete on public.period_logs to service_role;

-- Enable Row-Level Security (table is fully locked down until policies below)
alter table public.period_logs enable row level security;

-- SELECT: users can only read their own logs
create policy "period_logs_select_own"
  on public.period_logs
  for select
  to authenticated
  using (auth.uid() = user_id);

-- INSERT: users can only insert rows they own
create policy "period_logs_insert_own"
  on public.period_logs
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- UPDATE: users can only update their own logs (and can never transfer ownership)
create policy "period_logs_update_own"
  on public.period_logs
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- DELETE: users can only delete their own logs
create policy "period_logs_delete_own"
  on public.period_logs
  for delete
  to authenticated
  using (auth.uid() = user_id);