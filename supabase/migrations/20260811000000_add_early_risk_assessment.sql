alter table public.profiles
  add column if not exists early_risk_assessment jsonb;