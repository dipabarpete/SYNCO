alter table public.profiles
  add column if not exists diagnosed_by text,
  add column if not exists diagnosis_timeframe text,
  add column if not exists medication_status text,
  add column if not exists current_medications_or_supplements text,
  add column if not exists current_concerns text[] not null default '{}',
  add column if not exists other_concern text;
