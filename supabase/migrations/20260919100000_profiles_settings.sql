-- Profiles + user_settings. Metadatos no sensibles.
-- El OCR y los blobs NUNCA se guardan aquí.
--
-- RLS (documentado y activo):
--   authenticated solo ve / escribe sus filas (auth.uid() = id / user_id).
--   anon no tiene grants: el modo invitado es 100% local.
--   service_role no se usa desde la app.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users (id) on delete cascade,
  compression_profile text not null default 'balanced',
  backup_enabled boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.user_settings enable row level security;

drop policy if exists profiles_owner on public.profiles;
drop policy if exists user_settings_owner on public.user_settings;

create policy profiles_owner on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

create policy user_settings_owner on public.user_settings
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

grant select, insert, update, delete on public.profiles to authenticated;
grant select, insert, update, delete on public.user_settings to authenticated;

-- SyncQueue es solo local (Drift). No hay tabla remota:
-- la cola vive en el dispositivo y se vacía con el botón "Sincronizar".
