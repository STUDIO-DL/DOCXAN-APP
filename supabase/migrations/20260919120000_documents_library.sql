-- Library metadata for smart collections and last-write-wins sync.
-- Never store OCR plaintext or document blobs here.

alter table public.documents
  add column if not exists deleted_at timestamptz,
  add column if not exists page_count integer not null default 1,
  add column if not exists is_favorite boolean not null default false;

alter table public.folders
  add column if not exists icon_key text not null default 'folder';

create index if not exists documents_user_updated_idx
  on public.documents (user_id, updated_at desc);

create index if not exists documents_user_deleted_idx
  on public.documents (user_id, deleted_at);

-- Optional settings row. Missing table is fine on a fresh project that
-- only ran the init migration.
create table if not exists public.user_settings (
  user_id uuid primary key references auth.users (id) on delete cascade,
  compression_profile text not null default 'balanced',
  backup_enabled boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.user_settings enable row level security;

drop policy if exists user_settings_owner on public.user_settings;
create policy user_settings_owner on public.user_settings
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

grant select, insert, update, delete on public.user_settings to authenticated;
