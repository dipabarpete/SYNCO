-- Health tracker tables for the SYNCO Health module.
-- Each table holds one user's tracker entries; Row-Level Security guarantees
-- that users only ever read/write their own rows (auth.uid() = user_id).

-- SLEEP ---------------------------------------------------------------------
create table if not exists public.sleep_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  date date not null,
  start_minutes int check (start_minutes between 0 and 1439),
  end_minutes int check (end_minutes between 0 and 1439),
  duration_minutes int check (duration_minutes between 0 and 960),
  quality text check (quality in ('Poor', 'Okay', 'Good')),
  factors text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- WATER ---------------------------------------------------------------------
create table if not exists public.water_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  date date not null,
  quantity numeric not null check (quantity > 0),
  unit text not null check (unit in ('cups', 'fl oz')),
  hydration_level text check (hydration_level in ('Poor', 'Okay', 'Good')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- STEPS ---------------------------------------------------------------------
create table if not exists public.step_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  date date not null,
  count int not null check (count >= 0),
  source text not null default 'manual' check (source in ('manual', 'device')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- SUGAR CRAVINGS -------------------------------------------------------------
create table if not exists public.sugar_craving_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  date date not null,
  craving text not null,
  level text check (level in ('Low', 'Medium', 'High')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- SUPPLEMENTS ---------------------------------------------------------------
create table if not exists public.supplement_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  date date not null,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- MENTAL WELLNESS ------------------------------------------------------------
create table if not exists public.mental_wellness_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  date date not null,
  stress_level int check (stress_level between 1 and 5),
  anxiety_level int check (anxiety_level between 1 and 5),
  energy_level int check (energy_level between 1 and 5),
  sleep_quality text check (sleep_quality in ('Poor', 'Okay', 'Good')),
  mood text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- FOOD & NUTRITION -----------------------------------------------------------
create table if not exists public.food_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  date date not null,
  description text not null,
  meal_type text check (meal_type in ('Breakfast', 'Lunch', 'Dinner', 'Snack')),
  tags text[] not null default '{}',
  is_favorite boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- WEIGHT ---------------------------------------------------------------------
create table if not exists public.weight_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  date date not null,
  weight numeric not null check (weight > 0),
  unit text not null check (unit in ('kg', 'lb')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes for fast per-user, per-date queries --------------------------------
create index if not exists sleep_entries_user_date_idx on public.sleep_entries (user_id, date desc);
create index if not exists water_entries_user_date_idx on public.water_entries (user_id, date desc);
create index if not exists step_entries_user_date_idx on public.step_entries (user_id, date desc);
create index if not exists sugar_craving_user_date_idx on public.sugar_craving_entries (user_id, date desc);
create index if not exists supplement_user_date_idx on public.supplement_entries (user_id, date desc);
create index if not exists wellness_user_date_idx on public.mental_wellness_entries (user_id, date desc);
create index if not exists food_entries_user_date_idx on public.food_entries (user_id, date desc);
create index if not exists weight_entries_user_date_idx on public.weight_entries (user_id, date desc);

-- updated_at trigger helper ---------------------------------------------------
create or replace function public.health_entries_set_updated_at()
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

do $$
declare
  t text;
begin
  foreach t in array array['sleep_entries', 'water_entries', 'step_entries',
                          'sugar_craving_entries', 'supplement_entries',
                          'mental_wellness_entries', 'food_entries',
                          'weight_entries']
  loop
    execute format('drop trigger if exists %I_set_updated_at_trigger on public.%I', t, t);
    execute format(
      'create trigger %I_set_updated_at_trigger
         before update on public.%I
         for each row execute function public.health_entries_set_updated_at()',
      t, t);
  end loop;
end;
$$;

-- Grants (authenticated + service_role only; never anon) ---------------------
grant select, insert, update, delete
  on table public.sleep_entries, public.water_entries, public.step_entries,
             public.sugar_craving_entries, public.supplement_entries,
             public.mental_wellness_entries, public.food_entries,
             public.weight_entries
  to authenticated;

grant select, insert, update, delete
  on table public.sleep_entries, public.water_entries, public.step_entries,
             public.sugar_craving_entries, public.supplement_entries,
             public.mental_wellness_entries, public.food_entries,
             public.weight_entries
  to service_role;

-- Enable Row-Level Security on every table -------------------------------------
alter table public.sleep_entries enable row level security;
alter table public.water_entries enable row level security;
alter table public.step_entries enable row level security;
alter table public.sugar_craving_entries enable row level security;
alter table public.supplement_entries enable row level security;
alter table public.mental_wellness_entries enable row level security;
alter table public.food_entries enable row level security;
alter table public.weight_entries enable row level security;

-- RLS policies: users can only touch their own rows ---------------------------
do $$
declare
  t text;
begin
  foreach t in array array['sleep_entries', 'water_entries', 'step_entries',
                          'sugar_craving_entries', 'supplement_entries',
                          'mental_wellness_entries', 'food_entries',
                          'weight_entries']
  loop
    execute format('drop policy if exists %I_select_own on public.%I', t, t);
    execute format('drop policy if exists %I_insert_own on public.%I', t, t);
    execute format('drop policy if exists %I_update_own on public.%I', t, t);
    execute format('drop policy if exists %I_delete_own on public.%I', t, t);

    execute format(
      'create policy %I_select_own on public.%I for select to authenticated
         using (auth.uid() = user_id)', t, t);
    execute format(
      'create policy %I_insert_own on public.%I for insert to authenticated
         with check (auth.uid() = user_id)', t, t);
    execute format(
      'create policy %I_update_own on public.%I for update to authenticated
         using (auth.uid() = user_id) with check (auth.uid() = user_id)', t, t);
    execute format(
      'create policy %I_delete_own on public.%I for delete to authenticated
         using (auth.uid() = user_id)', t, t);
  end loop;
end;
$$;