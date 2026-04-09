-- Ejecuta este script en el SQL Editor de Supabase.
-- 1. Crea las tablas de cuentas, perfiles, articulos y notificaciones.
-- 2. Activa RLS y deja el rol admin securizado en base de datos.
-- 3. Despues de registrarte por primera vez, promociona tu usuario a admin:
--    insert into public.admin_users (user_id, email)
--    select id, email from public.profiles where email = 'TU_CORREO_REAL';

create extension if not exists pgcrypto;

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique,
  display_name text,
  first_name text,
  last_name text,
  phone text,
  city text,
  province text,
  country text,
  birth_date date,
  occupation text,
  website_url text,
  avatar_url text,
  main_topic text,
  bio text,
  notify_new_articles boolean not null default false,
  notify_browser boolean not null default false,
  notify_email boolean not null default false,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users (id) on delete cascade,
  email text not null unique,
  created_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.articles (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references public.profiles (id) on delete set null,
  slug text not null unique,
  title text not null,
  excerpt text not null,
  category text not null default 'General',
  read_time text,
  hero_note text,
  body_markdown text not null,
  is_featured boolean not null default false,
  status text not null default 'draft' check (status in ('draft', 'published')),
  published_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.article_notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  article_id uuid not null references public.articles (id) on delete cascade,
  is_read boolean not null default false,
  channel text not null default 'in_app',
  created_at timestamptz not null default timezone('utc', now()),
  unique (user_id, article_id)
);

create index if not exists idx_articles_status_published_at on public.articles (status, published_at desc);
create index if not exists idx_article_notifications_user_created on public.article_notifications (user_id, created_at desc);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  raw_display_name text;
  raw_first_name text;
  raw_last_name text;
begin
  raw_display_name := nullif(trim(coalesce(new.raw_user_meta_data ->> 'display_name', '')), '');
  raw_first_name := nullif(trim(coalesce(new.raw_user_meta_data ->> 'first_name', '')), '');
  raw_last_name := nullif(trim(coalesce(new.raw_user_meta_data ->> 'last_name', '')), '');

  insert into public.profiles (
    id,
    email,
    display_name,
    first_name,
    last_name
  )
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(raw_display_name, split_part(coalesce(new.email, ''), '@', 1)),
    raw_first_name,
    raw_last_name
  )
  on conflict (id) do update
  set
    email = excluded.email,
    display_name = coalesce(excluded.display_name, public.profiles.display_name),
    first_name = coalesce(excluded.first_name, public.profiles.first_name),
    last_name = coalesce(excluded.last_name, public.profiles.last_name),
    updated_at = timezone('utc', now());

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.is_admin(check_user uuid default auth.uid())
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admin_users
    where user_id = coalesce(check_user, auth.uid())
  );
$$;

create or replace function public.prepare_article_publication()
returns trigger
language plpgsql
as $$
begin
  if new.status = 'published' and old.status is distinct from 'published' then
    if new.published_at is null then
      new.published_at = timezone('utc', now());
    end if;
  end if;

  if new.status <> 'published' then
    new.published_at = null;
  end if;

  return new;
end;
$$;

create or replace function public.notify_new_article()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status = 'published' and (tg_op = 'INSERT' or old.status is distinct from 'published') then
    insert into public.article_notifications (user_id, article_id, channel)
    select
      p.id,
      new.id,
      case when p.notify_browser then 'browser' else 'in_app' end
    from public.profiles p
    where p.notify_new_articles = true
      and (new.author_id is null or p.id <> new.author_id)
    on conflict (user_id, article_id) do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
before update on public.profiles
for each row execute procedure public.touch_updated_at();

drop trigger if exists articles_touch_updated_at on public.articles;
create trigger articles_touch_updated_at
before update on public.articles
for each row execute procedure public.touch_updated_at();

drop trigger if exists articles_prepare_publication on public.articles;
create trigger articles_prepare_publication
before insert or update on public.articles
for each row execute procedure public.prepare_article_publication();

drop trigger if exists articles_notify_new_article_insert on public.articles;
create trigger articles_notify_new_article_insert
after insert on public.articles
for each row execute procedure public.notify_new_article();

drop trigger if exists articles_notify_new_article_update on public.articles;
create trigger articles_notify_new_article_update
after update on public.articles
for each row execute procedure public.notify_new_article();

alter table public.profiles enable row level security;
alter table public.admin_users enable row level security;
alter table public.articles enable row level security;
alter table public.article_notifications enable row level security;

drop policy if exists "profiles_select_self_or_admin" on public.profiles;
create policy "profiles_select_self_or_admin"
on public.profiles
for select
using (
  auth.uid() is not null
  and (auth.uid() = id or public.is_admin())
);

drop policy if exists "profiles_insert_self" on public.profiles;
create policy "profiles_insert_self"
on public.profiles
for insert
with check (
  auth.uid() is not null
  and auth.uid() = id
);

drop policy if exists "profiles_update_self_or_admin" on public.profiles;
create policy "profiles_update_self_or_admin"
on public.profiles
for update
using (
  auth.uid() is not null
  and (auth.uid() = id or public.is_admin())
)
with check (
  auth.uid() is not null
  and (auth.uid() = id or public.is_admin())
);

drop policy if exists "articles_public_select" on public.articles;
create policy "articles_public_select"
on public.articles
for select
using (
  status = 'published'
  or public.is_admin()
);

drop policy if exists "articles_admin_insert" on public.articles;
create policy "articles_admin_insert"
on public.articles
for insert
with check (public.is_admin());

drop policy if exists "articles_admin_update" on public.articles;
create policy "articles_admin_update"
on public.articles
for update
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "articles_admin_delete" on public.articles;
create policy "articles_admin_delete"
on public.articles
for delete
using (public.is_admin());

drop policy if exists "notifications_select_self_or_admin" on public.article_notifications;
create policy "notifications_select_self_or_admin"
on public.article_notifications
for select
using (
  auth.uid() is not null
  and (user_id = auth.uid() or public.is_admin())
);

drop policy if exists "notifications_update_self_or_admin" on public.article_notifications;
create policy "notifications_update_self_or_admin"
on public.article_notifications
for update
using (
  auth.uid() is not null
  and (user_id = auth.uid() or public.is_admin())
)
with check (
  auth.uid() is not null
  and (user_id = auth.uid() or public.is_admin())
);
