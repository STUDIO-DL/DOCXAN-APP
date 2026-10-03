-- Per-user fixed-window rate limiting for Edge Functions.
-- Only the service role (Edge Functions) may call rate_limit_hit; clients
-- cannot read or write the counters (RLS on, no policies, no grants).

create table if not exists public.rate_limits (
  user_id uuid not null references auth.users (id) on delete cascade,
  bucket text not null,
  window_start timestamptz not null,
  hits integer not null default 0,
  primary key (user_id, bucket)
);

alter table public.rate_limits enable row level security;

revoke all on table public.rate_limits from public, anon, authenticated;

-- Counts one hit for (p_user, p_bucket) in the current fixed window.
-- Returns 0 when allowed, otherwise the seconds until the window resets
-- (suitable for a Retry-After header).
create or replace function public.rate_limit_hit(
  p_user uuid,
  p_bucket text,
  p_limit integer,
  p_window_seconds integer
)
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_now timestamptz := now();
  v_window timestamptz;
  v_hits integer;
begin
  if p_user is null
     or p_bucket is null
     or length(p_bucket) > 64
     or p_limit is null or p_limit < 1
     or p_window_seconds is null or p_window_seconds < 1 then
    raise exception 'invalid rate limit arguments';
  end if;

  v_window := to_timestamp(
    (floor(extract(epoch from v_now) / p_window_seconds) * p_window_seconds)::double precision
  );

  insert into public.rate_limits as r (user_id, bucket, window_start, hits)
  values (p_user, p_bucket, v_window, 1)
  on conflict (user_id, bucket) do update
    set hits = case
          when r.window_start = excluded.window_start then r.hits + 1
          else 1
        end,
        window_start = excluded.window_start
  returning r.hits into v_hits;

  if v_hits <= p_limit then
    return 0;
  end if;

  return greatest(
    1,
    ceil(extract(epoch from (v_window + make_interval(secs => p_window_seconds) - v_now)))::integer
  );
end;
$$;

revoke all on function public.rate_limit_hit(uuid, text, integer, integer)
  from public, anon, authenticated;
grant execute on function public.rate_limit_hit(uuid, text, integer, integer)
  to service_role;
