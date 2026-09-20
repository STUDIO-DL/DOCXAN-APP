-- Docxan metadata. Never store OCR plaintext or document blobs here.
-- Guest mode is local-only: no grants to `anon`.
--
-- RLS: cada fila queda atada a auth.uid() = user_id.
-- sync_status en documents: local_only | pending_upload | uploading | synced | failed.

create table if not exists public.folders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  parent_id uuid references public.folders (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  folder_id uuid references public.folders (id) on delete set null,
  name text not null,
  format text not null,
  size_bytes bigint not null default 0,
  encrypted_hash text,
  sync_status text not null default 'local',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.backups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  document_id uuid not null references public.documents (id) on delete cascade,
  r2_key text not null,
  encrypted_size bigint not null,
  created_at timestamptz not null default now()
);

create index if not exists folders_user_id_idx on public.folders (user_id);
create index if not exists documents_user_id_idx on public.documents (user_id);
create index if not exists documents_folder_id_idx on public.documents (folder_id);
create index if not exists backups_user_id_idx on public.backups (user_id);

alter table public.folders enable row level security;
alter table public.documents enable row level security;
alter table public.backups enable row level security;

drop policy if exists folders_owner on public.folders;
drop policy if exists documents_owner on public.documents;
drop policy if exists backups_owner on public.backups;

create policy folders_owner on public.folders
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy documents_owner on public.documents
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy backups_owner on public.backups
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

grant usage on schema public to authenticated;

grant select, insert, update, delete on public.folders to authenticated;
grant select, insert, update, delete on public.documents to authenticated;
grant select, insert, update, delete on public.backups to authenticated;
