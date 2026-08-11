-- Fix: authenticated (and service_role) had NO table privileges on
-- public.period_logs in the live database, causing 42501 permission denied.
-- The GRANT statements added to 20260812000000_create_period_logs.sql were
-- never applied remotely (that migration already existed in remote history).
--
-- This migration only adds table-level privileges. RLS remains enabled and
-- the existing row-level policies are untouched. No privileges for anon.

grant select, insert, update, delete
  on table public.period_logs
  to authenticated;

grant select, insert, update, delete
  on table public.period_logs
  to service_role;