-- THE WARDROBE EDIT v0.8 — initial Supabase schema
-- Run this in Supabase SQL Editor. All user-owned records are protected by RLS.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id) values (new.id) on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create table if not exists public.garments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists garments_user_id_idx on public.garments(user_id);

create table if not exists public.outfits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists outfits_user_id_idx on public.outfits(user_id);

create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  outfit_id uuid references public.outfits(id) on delete set null,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists feedback_user_id_idx on public.feedback(user_id);

create table if not exists public.style_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.collections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists collections_user_id_idx on public.collections(user_id);

-- Enable Row Level Security on every private table.
alter table public.profiles enable row level security;
alter table public.garments enable row level security;
alter table public.outfits enable row level security;
alter table public.feedback enable row level security;
alter table public.style_profiles enable row level security;
alter table public.collections enable row level security;

drop policy if exists "profile owner can read" on public.profiles;
create policy "profile owner can read" on public.profiles for select to authenticated using ((select auth.uid()) = id);
drop policy if exists "profile owner can update" on public.profiles;
create policy "profile owner can update" on public.profiles for update to authenticated using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

-- Generic owner-only policies. user_id is always matched against the authenticated session.
do $$
declare t text;
begin
  foreach t in array array['garments','outfits','feedback','collections'] loop
    execute format('drop policy if exists %I on public.%I', t || ' owner access', t);
    execute format('create policy %I on public.%I for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id)', t || ' owner access', t);
  end loop;
end $$;
drop policy if exists "style profile owner access" on public.style_profiles;
create policy "style profile owner access" on public.style_profiles for all to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

-- Private garment image bucket. Create bucket through Storage UI with name 'wardrobe-images'
-- and mark it PRIVATE, then apply these policies.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('wardrobe-images','wardrobe-images',false,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=false, file_size_limit=5242880, allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists "users can read own wardrobe images" on storage.objects;
create policy "users can read own wardrobe images" on storage.objects for select to authenticated using (bucket_id='wardrobe-images' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "users can upload own wardrobe images" on storage.objects;
create policy "users can upload own wardrobe images" on storage.objects for insert to authenticated with check (bucket_id='wardrobe-images' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "users can update own wardrobe images" on storage.objects;
create policy "users can update own wardrobe images" on storage.objects for update to authenticated using (bucket_id='wardrobe-images' and (storage.foldername(name))[1]=(select auth.uid())::text) with check (bucket_id='wardrobe-images' and (storage.foldername(name))[1]=(select auth.uid())::text);
drop policy if exists "users can delete own wardrobe images" on storage.objects;
create policy "users can delete own wardrobe images" on storage.objects for delete to authenticated using (bucket_id='wardrobe-images' and (storage.foldername(name))[1]=(select auth.uid())::text);
