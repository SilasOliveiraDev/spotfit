-- SpotFit schema: catálogo, playlists de treino, favoritos e base para compartilhar.
create schema if not exists private;

create or replace function private.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default 'Atleta',
  fitness_focus text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.tracks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  artist text not null,
  duration_ms integer not null default 0,
  audio_url text not null,
  cover_url text,
  bpm integer,
  workout_tags text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.playlists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users (id) on delete cascade,
  title text not null,
  description text,
  cover_url text,
  workout_type text not null default 'treino',
  is_public boolean not null default false,
  is_official boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint playlists_owner_or_official check (user_id is not null or is_official)
);

create table if not exists public.playlist_tracks (
  playlist_id uuid not null references public.playlists (id) on delete cascade,
  track_id uuid not null references public.tracks (id) on delete cascade,
  position integer not null,
  added_at timestamptz not null default now(),
  primary key (playlist_id, track_id)
);

create table if not exists public.favorites (
  user_id uuid not null references auth.users (id) on delete cascade,
  track_id uuid not null references public.tracks (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, track_id)
);

create table if not exists public.playlist_shares (
  id uuid primary key default gen_random_uuid(),
  playlist_id uuid not null references public.playlists (id) on delete cascade,
  owner_id uuid not null references auth.users (id) on delete cascade,
  shared_with uuid references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function private.set_updated_at();

drop trigger if exists playlists_set_updated_at on public.playlists;
create trigger playlists_set_updated_at
before update on public.playlists
for each row execute function private.set_updated_at();

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1), 'Atleta')
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function private.handle_new_user();

alter table public.profiles enable row level security;
alter table public.tracks enable row level security;
alter table public.playlists enable row level security;
alter table public.playlist_tracks enable row level security;
alter table public.favorites enable row level security;
alter table public.playlist_shares enable row level security;

drop policy if exists "profiles_select_authenticated" on public.profiles;
create policy "profiles_select_authenticated"
on public.profiles for select to authenticated
using (true);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update to authenticated
using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists "tracks_read_all" on public.tracks;
create policy "tracks_read_all"
on public.tracks for select to anon, authenticated
using (true);

drop policy if exists "playlists_read_visible" on public.playlists;
create policy "playlists_read_visible"
on public.playlists for select to anon, authenticated
using (is_official or is_public or user_id = auth.uid());

drop policy if exists "playlists_insert_own" on public.playlists;
create policy "playlists_insert_own"
on public.playlists for insert to authenticated
with check (user_id = auth.uid() and is_official = false);

drop policy if exists "playlists_update_own" on public.playlists;
create policy "playlists_update_own"
on public.playlists for update to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid() and is_official = false);

drop policy if exists "playlists_delete_own" on public.playlists;
create policy "playlists_delete_own"
on public.playlists for delete to authenticated
using (user_id = auth.uid());

drop policy if exists "playlist_tracks_read" on public.playlist_tracks;
create policy "playlist_tracks_read"
on public.playlist_tracks for select to anon, authenticated
using (
  exists (
    select 1 from public.playlists p
    where p.id = playlist_id
      and (p.is_official or p.is_public or p.user_id = auth.uid())
  )
);

drop policy if exists "playlist_tracks_write_own" on public.playlist_tracks;
create policy "playlist_tracks_write_own"
on public.playlist_tracks for insert to authenticated
with check (
  exists (
    select 1 from public.playlists p
    where p.id = playlist_id and p.user_id = auth.uid()
  )
);

drop policy if exists "playlist_tracks_delete_own" on public.playlist_tracks;
create policy "playlist_tracks_delete_own"
on public.playlist_tracks for delete to authenticated
using (
  exists (
    select 1 from public.playlists p
    where p.id = playlist_id and p.user_id = auth.uid()
  )
);

drop policy if exists "favorites_own_all" on public.favorites;
create policy "favorites_select_own"
on public.favorites for select to authenticated
using (user_id = auth.uid());

create policy "favorites_insert_own"
on public.favorites for insert to authenticated
with check (user_id = auth.uid());

create policy "favorites_delete_own"
on public.favorites for delete to authenticated
using (user_id = auth.uid());

drop policy if exists "shares_select" on public.playlist_shares;
create policy "shares_select"
on public.playlist_shares for select to authenticated
using (owner_id = auth.uid() or shared_with = auth.uid());

create policy "shares_insert_own"
on public.playlist_shares for insert to authenticated
with check (owner_id = auth.uid());

create policy "shares_delete_own"
on public.playlist_shares for delete to authenticated
using (owner_id = auth.uid());

grant usage on schema public to anon, authenticated;
grant select on public.tracks to anon, authenticated;
grant select on public.playlists to anon, authenticated;
grant select on public.playlist_tracks to anon, authenticated;
grant select, update on public.profiles to authenticated;
grant insert, update, delete on public.playlists to authenticated;
grant insert, delete on public.playlist_tracks to authenticated;
grant select, insert, delete on public.favorites to authenticated;
grant select, insert, delete on public.playlist_shares to authenticated;

insert into public.tracks (id, title, artist, duration_ms, audio_url, cover_url, bpm, workout_tags)
values
  ('11111111-1111-4111-8111-111111111101', 'Pulse Run', 'SpotFit Radio', 372000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 'https://picsum.photos/seed/pulse-run/640/640', 168, array['cardio','hiit']),
  ('11111111-1111-4111-8111-111111111102', 'Sprint City', 'Cadence Lab', 384000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', 'https://picsum.photos/seed/sprint-city/640/640', 174, array['cardio']),
  ('11111111-1111-4111-8111-111111111103', 'Iron Set', 'Forge Beats', 396000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', 'https://picsum.photos/seed/iron-set/640/640', 92, array['muscle']),
  ('11111111-1111-4111-8111-111111111104', 'Heavy Rep', 'Forge Beats', 354000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3', 'https://picsum.photos/seed/heavy-rep/640/640', 88, array['muscle']),
  ('11111111-1111-4111-8111-111111111105', 'Box Jump', 'HIIT Club', 318000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3', 'https://picsum.photos/seed/box-jump/640/640', 160, array['hiit','cardio']),
  ('11111111-1111-4111-8111-111111111106', 'Tabata Fire', 'HIIT Club', 300000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3', 'https://picsum.photos/seed/tabata-fire/640/640', 170, array['hiit']),
  ('11111111-1111-4111-8111-111111111107', 'Flow Breath', 'Studio Balance', 420000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3', 'https://picsum.photos/seed/flow-breath/640/640', 72, array['yoga','cooldown']),
  ('11111111-1111-4111-8111-111111111108', 'Sun Salute', 'Studio Balance', 408000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3', 'https://picsum.photos/seed/sun-salute/640/640', 78, array['yoga','warmup']),
  ('11111111-1111-4111-8111-111111111109', 'Ignite', 'Warmup Crew', 246000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3', 'https://picsum.photos/seed/ignite/640/640', 118, array['warmup']),
  ('11111111-1111-4111-8111-111111111110', 'Mobility Loop', 'Warmup Crew', 264000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3', 'https://picsum.photos/seed/mobility/640/640', 110, array['warmup','yoga']),
  ('11111111-1111-4111-8111-111111111111', 'Slow Down', 'Afterburn', 390000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3', 'https://picsum.photos/seed/slow-down/640/640', 68, array['cooldown']),
  ('11111111-1111-4111-8111-111111111112', 'Stretch Night', 'Afterburn', 402000, 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3', 'https://picsum.photos/seed/stretch-night/640/640', 64, array['cooldown','yoga'])
on conflict (id) do nothing;

insert into public.playlists (id, title, description, cover_url, workout_type, is_public, is_official)
values
  ('22222222-2222-4222-8222-222222222201', 'Cardio Endurance', 'BPM alto para corrida, bike e esteira.', 'https://picsum.photos/seed/pl-cardio/640/640', 'cardio', true, true),
  ('22222222-2222-4222-8222-222222222202', 'Muscle Power', 'Groove pesado para séries de força.', 'https://picsum.photos/seed/pl-muscle/640/640', 'muscle', true, true),
  ('22222222-2222-4222-8222-222222222203', 'HIIT Blast', 'Intervalos curtos, energia máxima.', 'https://picsum.photos/seed/pl-hiit/640/640', 'hiit', true, true),
  ('22222222-2222-4222-8222-222222222204', 'Yoga Flow', 'Respiração e mobilidade.', 'https://picsum.photos/seed/pl-yoga/640/640', 'yoga', true, true),
  ('22222222-2222-4222-8222-222222222205', 'Aquecimento', '5 a 10 minutos para entrar no treino.', 'https://picsum.photos/seed/pl-warmup/640/640', 'warmup', true, true),
  ('22222222-2222-4222-8222-222222222206', 'Desacelerar', 'Volta à calma e alongamento.', 'https://picsum.photos/seed/pl-cooldown/640/640', 'cooldown', true, true)
on conflict (id) do nothing;

insert into public.playlist_tracks (playlist_id, track_id, position)
values
  ('22222222-2222-4222-8222-222222222201', '11111111-1111-4111-8111-111111111101', 0),
  ('22222222-2222-4222-8222-222222222201', '11111111-1111-4111-8111-111111111102', 1),
  ('22222222-2222-4222-8222-222222222201', '11111111-1111-4111-8111-111111111105', 2),
  ('22222222-2222-4222-8222-222222222202', '11111111-1111-4111-8111-111111111103', 0),
  ('22222222-2222-4222-8222-222222222202', '11111111-1111-4111-8111-111111111104', 1),
  ('22222222-2222-4222-8222-222222222202', '11111111-1111-4111-8111-111111111109', 2),
  ('22222222-2222-4222-8222-222222222203', '11111111-1111-4111-8111-111111111106', 0),
  ('22222222-2222-4222-8222-222222222203', '11111111-1111-4111-8111-111111111105', 1),
  ('22222222-2222-4222-8222-222222222203', '11111111-1111-4111-8111-111111111101', 2),
  ('22222222-2222-4222-8222-222222222204', '11111111-1111-4111-8111-111111111107', 0),
  ('22222222-2222-4222-8222-222222222204', '11111111-1111-4111-8111-111111111108', 1),
  ('22222222-2222-4222-8222-222222222204', '11111111-1111-4111-8111-111111111112', 2),
  ('22222222-2222-4222-8222-222222222205', '11111111-1111-4111-8111-111111111109', 0),
  ('22222222-2222-4222-8222-222222222205', '11111111-1111-4111-8111-111111111110', 1),
  ('22222222-2222-4222-8222-222222222205', '11111111-1111-4111-8111-111111111108', 2),
  ('22222222-2222-4222-8222-222222222206', '11111111-1111-4111-8111-111111111111', 0),
  ('22222222-2222-4222-8222-222222222206', '11111111-1111-4111-8111-111111111112', 1),
  ('22222222-2222-4222-8222-222222222206', '11111111-1111-4111-8111-111111111107', 2)
on conflict do nothing;
