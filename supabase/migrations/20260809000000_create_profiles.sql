-- Base profiles table used by the SYNCO app.
-- Column set mirrors what lib/models/user_profile.dart and
-- lib/features/auth/services/auth_service.dart read or write.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text,
  email text,
  phone text,
  avatar_url text,
  onboarding_completed boolean not null default false,
  is_partner_linked boolean not null default false,
  partner_code text,
  partner_name text,
  age int,
  weight_kg numeric,
  height_cm numeric,
  role text not null default 'user' check (role in ('user', 'doctor')),
  diagnosis_status text not null default 'prefer_not_to_say'
    check (diagnosis_status in ('diagnosed', 'not_diagnosed', 'prefer_not_to_say')),
  diagnosed_by text,
  diagnosis_timeframe text,
  medication_status text,
  current_medications_or_supplements text,
  current_concerns text[] not null default '{}',
  other_concern text,
  period_regularity text,
  average_cycle_length_days int,
  recent_symptom_change text,
  lab_report_availability text,
  lab_reports jsonb not null default '[]',
  primary_goal text,
  early_risk_assessment jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Keep updated_at fresh on any update (same convention as period_logs)
create or replace function public.profiles_set_updated_at()
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

drop trigger if exists profiles_set_updated_at_trigger on public.profiles;
create trigger profiles_set_updated_at_trigger
  before update on public.profiles
  for each row execute function public.profiles_set_updated_at();

-- Table-wide grants (matches Supabase's default public-schema grants)
grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.profiles to service_role;

-- Row-Level Security: every user can only touch their own profile
alter table public.profiles enable row level security;

create policy "profiles_select_own"
  on public.profiles
  for select
  to authenticated
  using (auth.uid() = id);

create policy "profiles_insert_own"
  on public.profiles
  for insert
  to authenticated
  with check (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles
  for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "profiles_delete_own"
  on public.profiles
  for delete
  to authenticated
  using (auth.uid() = id);