-- =============================================================================
-- EarthGuard AI — Phase 2 Supabase schema
-- Run this whole file once in the Supabase SQL Editor.
-- Safe to re-run: uses IF NOT EXISTS and idempotent seeds.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 0. Extensions
-- ---------------------------------------------------------------------------
create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- 1. profiles (1:1 with auth.users)
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id         uuid primary key references auth.users(id) on delete cascade,
  full_name  text not null default '',
  phone      text,
  city       text,
  province   text,
  role       text not null default 'citizen'
             check (role in ('citizen', 'rescuer', 'admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Auto-create a profile whenever a user signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, phone, city, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'city',
    -- First registered account becomes the admin (demo convenience).
    case
      when not exists (select 1 from public.profiles p where p.role = 'admin')
        then 'admin'
      else 'citizen'
    end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Is the current user an admin? SECURITY DEFINER avoids RLS recursion.
-- Defined after profiles so the SQL body validates.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role = 'admin'
  );
$$;

-- ---------------------------------------------------------------------------
-- 2. Reference + operational tables
-- ---------------------------------------------------------------------------
create table if not exists public.disasters (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  type        text not null,
  severity    text not null check (severity in ('critical', 'high', 'moderate', 'low')),
  status      text not null default 'active'
              check (status in ('active', 'monitoring', 'resolved')),
  location    text not null,
  province    text,
  lat         double precision,
  lng         double precision,
  affected    integer not null default 0,
  radius_km   integer not null default 0,
  description text,
  started_at  timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

create table if not exists public.alerts (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  body       text,
  severity   text not null check (severity in ('critical', 'high', 'moderate', 'low', 'info')),
  region     text,
  channel    text not null default 'push',
  created_at timestamptz not null default now()
);

create table if not exists public.rescue_teams (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  type       text,
  status     text not null default 'available'
             check (status in ('available', 'on_mission', 'standby', 'offline')),
  members    integer not null default 0,
  province   text,
  lat        double precision,
  lng        double precision,
  equipment  text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.shelters (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  city       text,
  province   text,
  capacity   integer not null default 0,
  occupancy  integer not null default 0,
  facilities text[] not null default '{}',
  lat        double precision,
  lng        double precision,
  status     text not null default 'open'
             check (status in ('open', 'full', 'closed')),
  created_at timestamptz not null default now()
);

create table if not exists public.sos_requests (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid references auth.users(id) on delete set null,
  type             text not null,
  severity         text not null default 'high'
                   check (severity in ('critical', 'high', 'moderate', 'low')),
  status           text not null default 'pending'
                   check (status in ('pending', 'assigned', 'en_route', 'resolved', 'cancelled')),
  location         text,
  lat              double precision,
  lng              double precision,
  notes            text,
  assigned_team_id uuid references public.rescue_teams(id) on delete set null,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table if not exists public.risk_scores (
  id         uuid primary key default gen_random_uuid(),
  region     text not null unique,
  score      integer not null check (score between 0 and 100),
  hazards    jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

-- Keep sos_requests.updated_at fresh.
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists sos_requests_touch on public.sos_requests;
create trigger sos_requests_touch
  before update on public.sos_requests
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- 3. Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles      enable row level security;
alter table public.disasters     enable row level security;
alter table public.alerts        enable row level security;
alter table public.rescue_teams  enable row level security;
alter table public.shelters      enable row level security;
alter table public.sos_requests  enable row level security;
alter table public.risk_scores   enable row level security;

-- profiles ------------------------------------------------------------------
drop policy if exists profiles_select_self_or_admin on public.profiles;
create policy profiles_select_self_or_admin on public.profiles
  for select using (auth.uid() = id or public.is_admin());

drop policy if exists profiles_update_self on public.profiles;
create policy profiles_update_self on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- Reference data: authenticated read, admin write -------------------------
do $$
declare
  t text;
begin
  foreach t in array array['disasters', 'alerts', 'rescue_teams', 'shelters', 'risk_scores']
  loop
    execute format('drop policy if exists %I_read on public.%I', t, t);
    execute format(
      'create policy %I_read on public.%I for select using (auth.role() = ''authenticated'')',
      t, t
    );
    execute format('drop policy if exists %I_admin_write on public.%I', t, t);
    execute format(
      'create policy %I_admin_write on public.%I for all using (public.is_admin()) with check (public.is_admin())',
      t, t
    );
  end loop;
end $$;

-- SOS: own rows for citizens, all rows for admins --------------------------
drop policy if exists sos_insert_own on public.sos_requests;
create policy sos_insert_own on public.sos_requests
  for insert with check (auth.uid() = user_id);

drop policy if exists sos_select_own_or_admin on public.sos_requests;
create policy sos_select_own_or_admin on public.sos_requests
  for select using (auth.uid() = user_id or public.is_admin());

drop policy if exists sos_update_own_or_admin on public.sos_requests;
create policy sos_update_own_or_admin on public.sos_requests
  for update using (auth.uid() = user_id or public.is_admin())
  with check (auth.uid() = user_id or public.is_admin());

-- ---------------------------------------------------------------------------
-- 4. Realtime for the SOS dispatch board
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'sos_requests'
  ) then
    alter publication supabase_realtime add table public.sos_requests;
  end if;
end $$;

alter table public.sos_requests replica identity full;

-- ---------------------------------------------------------------------------
-- 5. Seed data (Pakistan context) — only inserts when tables are empty
-- ---------------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from public.disasters) then
    insert into public.disasters
      (title, type, severity, status, location, province, lat, lng, affected, radius_km, description, started_at)
    values
      ('Kotri Floods 2026', 'Flood', 'critical', 'active', 'Kotri, Jamshoro', 'Sindh', 25.3667, 68.3167, 148000, 42, 'Indus river breach after sustained monsoon rainfall; 24 relief camps active.', now() - interval '3 days'),
      ('Chitral Earthquake Swarm', 'Earthquake', 'high', 'monitoring', 'Chitral', 'Khyber Pakhtunkhwa', 35.8510, 71.7860, 12400, 18, 'Cluster of shallow tremors; structural assessments underway in Upper Chitral.', now() - interval '1 day'),
      ('Sibi Heatwave', 'Heatwave', 'high', 'active', 'Sibi', 'Balochistan', 29.5430, 67.8770, 38600, 25, 'Temperatures above 49°C; heatstroke response units deployed.', now() - interval '2 days'),
      ('N-35 Landslide', 'Landslide', 'moderate', 'active', 'N-35, Mansehra', 'Khyber Pakhtunkhwa', 34.3339, 73.1980, 2400, 6, 'Highway blocked near Battal; alternate route via Naran advised.', now() - interval '12 hours'),
      ('Cyclone AS-04', 'Cyclone', 'moderate', 'monitoring', 'Coastal Belt', 'Sindh', 24.8607, 67.0011, 96000, 120, 'System 480 km south-east of Karachi, tracking north-west.', now() - interval '6 hours'),
      ('Tharparkar Drought', 'Drought', 'low', 'monitoring', 'Tharparkar', 'Sindh', 24.7300, 70.1500, 52000, 80, 'Below-average rainfall for third consecutive season; water trucking continues.', now() - interval '14 days');
  end if;

  if not exists (select 1 from public.alerts) then
    insert into public.alerts (title, body, severity, region, channel) values
      ('Indus Flood Warning', 'Water levels at Kotri barrage rising; evacuate low-lying settlements.', 'critical', 'Sindh', 'push'),
      ('Aftershock Advisory', 'Magnitude 4.2 aftershock recorded near Chitral. Avoid damaged structures.', 'high', 'Khyber Pakhtunkhwa', 'push'),
      ('Heatwave Emergency', 'Sibi temperatures to peak at 50°C. Stay indoors 11am–5pm.', 'high', 'Balochistan', 'sms'),
      ('Landslide Route Closure', 'N-35 blocked near Battal. Use Naran bypass.', 'moderate', 'Khyber Pakhtunkhwa', 'push'),
      ('Cyclone Watch', 'AS-04 may intensify. Coastal fishermen advised to remain ashore.', 'moderate', 'Sindh', 'push'),
      ('Relief Camp Update', '24 camps operational in Jamshoro district with food and medical aid.', 'info', 'Sindh', 'app');
  end if;

  if not exists (select 1 from public.rescue_teams) then
    insert into public.rescue_teams (name, type, status, members, province, lat, lng, equipment) values
      ('Team Summit', 'Mountain Rescue', 'on_mission', 8, 'Khyber Pakhtunkhwa', 35.8510, 71.7860, array['Ropes', 'Stretchers', 'Thermal drones']),
      ('Team Indus', 'Flood Rescue', 'on_mission', 12, 'Sindh', 25.3667, 68.3167, array['Boats', 'Sonar', 'Life vests']),
      ('Team Raptor', 'Urban Search', 'available', 10, 'Punjab', 31.5204, 74.3587, array['Concrete cutters', 'K9 units']),
      ('Team Quetta', 'Medical Response', 'standby', 6, 'Balochistan', 30.1798, 66.9750, array['Ambulances', 'Trauma kits']);
  end if;

  if not exists (select 1 from public.shelters) then
    insert into public.shelters (name, city, province, capacity, occupancy, facilities, lat, lng, status) values
      ('Govt. Boys School Kotri', 'Kotri', 'Sindh', 600, 540, array['Food', 'Medical', 'Water'], 25.3667, 68.3167, 'open'),
      ('Chitral Scouts Hall', 'Chitral', 'Khyber Pakhtunkhwa', 350, 210, array['Heating', 'Medical'], 35.8510, 71.7860, 'open'),
      ('Sibi Sports Complex', 'Sibi', 'Balochistan', 800, 760, array['Cooling', 'Water', 'Medical'], 29.5430, 67.8770, 'full'),
      ('Mansehra Relief Camp', 'Mansehra', 'Khyber Pakhtunkhwa', 450, 180, array['Food', 'Water'], 34.3339, 73.1980, 'open'),
      ('Karachi Expo Centre', 'Karachi', 'Sindh', 1200, 430, array['Medical', 'Food', 'Water', 'Power'], 24.8607, 67.0011, 'open'),
      ('Tharparkar Community Hall', 'Mithi', 'Sindh', 300, 95, array['Water'], 24.7300, 70.1500, 'open');
  end if;

  if not exists (select 1 from public.risk_scores) then
    insert into public.risk_scores (region, score, hazards) values
      ('Lahore, Punjab', 62, '[{"hazard":"Flood","score":72},{"hazard":"Heatwave","score":68},{"hazard":"Air quality","score":55}]'::jsonb),
      ('Karachi, Sindh', 74, '[{"hazard":"Cyclone","score":81},{"hazard":"Flood","score":70},{"hazard":"Heatwave","score":64}]'::jsonb),
      ('Chitral, KP', 58, '[{"hazard":"Earthquake","score":77},{"hazard":"Landslide","score":61},{"hazard":"Flood","score":44}]'::jsonb),
      ('Quetta, Balochistan', 49, '[{"hazard":"Earthquake","score":66},{"hazard":"Drought","score":52},{"hazard":"Heatwave","score":47}]'::jsonb);
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- Done. Promote your first admin (replace the email):
--
-- update public.profiles p
-- set role = 'admin'
-- from auth.users u
-- where u.id = p.id and u.email = 'admin@earthguard.pk';
-- ---------------------------------------------------------------------------
