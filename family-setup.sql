-- Name Duel: Family & Friends backend. Paste into Supabase > SQL Editor > Run.
-- 1) Change CHOOSE-A-SECRET below to your own admin key (you'll type it in Settings to publish).

create table if not exists family_list (
  id int primary key check (id = 1),
  names jsonb not null default '[]',
  admin_key text not null,
  updated_at timestamptz not null default now()
);
create table if not exists family_attempts (
  id uuid primary key default gen_random_uuid(),
  person text not null,
  pin_hash text not null,
  picks jsonb not null,
  created_at timestamptz not null default now()
);
insert into family_list (id, names, admin_key) values (1, '[]', 'CHOOSE-A-SECRET') on conflict (id) do nothing;

-- Tables are locked (RLS on, no policies). Only the functions below can touch them.
alter table family_list enable row level security;
alter table family_attempts enable row level security;

create or replace function family_get_list() returns jsonb language sql security definer set search_path = public as $$
  select coalesce((select names from family_list where id = 1), '[]'::jsonb) $$;

create or replace function family_publish(p_key text, p_names jsonb) returns void language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from family_list where id = 1 and admin_key = p_key) then raise exception 'Wrong admin key'; end if;
  update family_list set names = p_names, updated_at = now() where id = 1;
end $$;

create or replace function family_login(p_person text, p_hash text) returns text language plpgsql security definer set search_path = public as $$
declare h text;
begin
  select pin_hash into h from family_attempts where lower(person) = lower(trim(p_person)) limit 1;
  if h is null then return 'new'; elsif h = p_hash then return 'ok'; else return 'bad'; end if;
end $$;

create or replace function family_my_attempts(p_person text, p_hash text) returns table (id uuid, created_at timestamptz, picks jsonb) language sql security definer set search_path = public as $$
  select a.id, a.created_at, a.picks from family_attempts a
  where lower(a.person) = lower(trim(p_person)) and a.pin_hash = p_hash order by a.created_at desc $$;

create or replace function family_submit(p_person text, p_hash text, p_picks jsonb) returns void language plpgsql security definer set search_path = public as $$
begin
  if length(trim(p_person)) = 0 or length(p_person) > 40 then raise exception 'Invalid name'; end if;
  if exists (select 1 from family_attempts where lower(person) = lower(trim(p_person)) and pin_hash <> p_hash) then raise exception 'That name is taken with a different PIN'; end if;
  insert into family_attempts (person, pin_hash, picks) values (trim(p_person), p_hash, p_picks);
end $$;

-- Combined picks per person: every chunk they rated, newest pick wins for each name
create or replace function family_results() returns table (person text, picks jsonb, created_at timestamptz) language sql security definer set search_path = public as $$
  with kv as (
    select distinct on (lower(a.person), e.key) a.person, e.key as k, e.value as v, a.created_at as ts
    from family_attempts a, jsonb_each(a.picks) e order by lower(a.person), e.key, a.created_at desc)
  select (array_agg(person))[1], jsonb_object_agg(k, v), max(ts) from kv group by lower(person) $$;

grant execute on function family_get_list(), family_publish(text, jsonb), family_login(text, text), family_my_attempts(text, text), family_submit(text, text, jsonb), family_results() to anon;

-- Meg & Cathleen's duel progress (so friends can see it). Run this once more if you set up earlier.
create table if not exists duel_status (
  id int primary key check (id = 1),
  status jsonb not null default '{}',
  updated_at timestamptz not null default now()
);
insert into duel_status (id) values (1) on conflict (id) do nothing;
alter table duel_status enable row level security;
create or replace function duel_get() returns jsonb language sql security definer set search_path = public as $$
  select coalesce((select status from duel_status where id = 1), '{}'::jsonb) $$;
create or replace function duel_publish(p_key text, p_status jsonb) returns void language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from family_list where id = 1 and admin_key = p_key) then raise exception 'Wrong admin key'; end if;
  update duel_status set status = p_status, updated_at = now() where id = 1;
end $$;
grant execute on function duel_get(), duel_publish(text, jsonb) to anon;

-- Everyone's history (friends and family)
create or replace function family_history() returns table (person text, created_at timestamptz, picks jsonb) language sql security definer set search_path = public as $$
  select a.person, a.created_at, a.picks from family_attempts a order by a.created_at desc limit 300 $$;
grant execute on function family_history() to anon;
