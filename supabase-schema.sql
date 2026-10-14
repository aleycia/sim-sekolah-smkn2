-- SIM SEKOLAH SMK NEGERI 2 SURAKARTA
-- Jalankan seluruh file ini di Supabase Dashboard > SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  role text not null default 'siswa' check (role in ('admin','guru','siswa')),
  created_at timestamptz not null default now()
);
create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  nis text not null unique,
  nama text not null,
  kelas text not null,
  jurusan text not null,
  email text,
  status text not null default 'Aktif' check(status in ('Aktif','Lulus','Pindah')),
  created_at timestamptz not null default now()
);
create table if not exists public.teachers (
  id uuid primary key default gen_random_uuid(),
  nip text not null unique,
  nama text not null,
  mapel text not null,
  email text,
  telepon text,
  created_at timestamptz not null default now()
);
create table if not exists public.schedules (
  id uuid primary key default gen_random_uuid(),
  kelas text not null,
  hari text not null,
  jam text not null,
  mapel text not null,
  guru text not null,
  ruang text,
  created_at timestamptz not null default now()
);
create table if not exists public.grades (
  id uuid primary key default gen_random_uuid(),
  nis text not null,
  nama_siswa text not null,
  mapel text not null,
  semester text not null check(semester in ('Ganjil','Genap')),
  nilai numeric(5,2) not null check(nilai between 0 and 100),
  predikat text,
  created_at timestamptz not null default now()
);
create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  tanggal date not null,
  nis text not null,
  nama_siswa text not null,
  kelas text not null,
  status text not null check(status in ('Hadir','Izin','Sakit','Alpa')),
  created_at timestamptz not null default now()
);
create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  judul text not null,
  kategori text not null default 'Umum',
  tanggal date not null default current_date,
  isi text not null,
  created_at timestamptz not null default now()
);

-- Isi nama profil otomatis saat akun mendaftar. Role default tetap siswa.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name',''), 'siswa')
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Aktifkan RLS untuk semua tabel.
alter table public.profiles enable row level security;
alter table public.students enable row level security;
alter table public.teachers enable row level security;
alter table public.schedules enable row level security;
alter table public.grades enable row level security;
alter table public.attendance enable row level security;
alter table public.announcements enable row level security;

-- Helper memeriksa peran pengguna yang sedang login.
create or replace function public.current_role()
returns text language sql stable security definer set search_path = '' as $$
  select role from public.profiles where id = (select auth.uid())
$$;

-- Profil: pengguna dapat membaca/mengubah profilnya sendiri; admin dapat membaca semuanya.
create policy "profile read self or admin" on public.profiles for select to authenticated
using (id = (select auth.uid()) or public.current_role() = 'admin');
-- Cegah pengguna menaikkan role sendiri melalui update profil.
create or replace function public.prevent_role_escalation()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.role is distinct from old.role
     and public.current_role() <> 'admin' then
    raise exception 'Only an admin can change profile roles';
  end if;
  return new;
end;
$$;
drop trigger if exists protect_profile_role on public.profiles;
create trigger protect_profile_role before update on public.profiles
for each row execute procedure public.prevent_role_escalation();

create policy "profile update self" on public.profiles for update to authenticated
using (id = (select auth.uid())) with check (id = (select auth.uid()));
-- Data sekolah: pengguna login dapat membaca; hanya admin yang boleh menulis.
create policy "students read authenticated" on public.students for select to authenticated using (true);
create policy "students admin insert" on public.students for insert to authenticated with check (public.current_role()='admin');
create policy "students admin update" on public.students for update to authenticated using (public.current_role()='admin') with check (public.current_role()='admin');
create policy "students admin delete" on public.students for delete to authenticated using (public.current_role()='admin');

create policy "teachers read authenticated" on public.teachers for select to authenticated using (true);
create policy "teachers admin insert" on public.teachers for insert to authenticated with check (public.current_role()='admin');
create policy "teachers admin update" on public.teachers for update to authenticated using (public.current_role()='admin') with check (public.current_role()='admin');
create policy "teachers admin delete" on public.teachers for delete to authenticated using (public.current_role()='admin');

create policy "schedules read authenticated" on public.schedules for select to authenticated using (true);
create policy "schedules admin insert" on public.schedules for insert to authenticated with check (public.current_role()='admin');
create policy "schedules admin update" on public.schedules for update to authenticated using (public.current_role()='admin') with check (public.current_role()='admin');
create policy "schedules admin delete" on public.schedules for delete to authenticated using (public.current_role()='admin');

create policy "grades read authenticated" on public.grades for select to authenticated using (true);
create policy "grades admin insert" on public.grades for insert to authenticated with check (public.current_role()='admin');
create policy "grades admin update" on public.grades for update to authenticated using (public.current_role()='admin') with check (public.current_role()='admin');
create policy "grades admin delete" on public.grades for delete to authenticated using (public.current_role()='admin');

create policy "attendance read authenticated" on public.attendance for select to authenticated using (true);
create policy "attendance admin insert" on public.attendance for insert to authenticated with check (public.current_role()='admin');
create policy "attendance admin update" on public.attendance for update to authenticated using (public.current_role()='admin') with check (public.current_role()='admin');
create policy "attendance admin delete" on public.attendance for delete to authenticated using (public.current_role()='admin');

create policy "announcements read authenticated" on public.announcements for select to authenticated using (true);
create policy "announcements admin insert" on public.announcements for insert to authenticated with check (public.current_role()='admin');
create policy "announcements admin update" on public.announcements for update to authenticated using (public.current_role()='admin') with check (public.current_role()='admin');
create policy "announcements admin delete" on public.announcements for delete to authenticated using (public.current_role()='admin') with check (public.current_role()='admin');

-- PENTING: Setelah akun pertama dibuat, promosikan menjadi admin dari SQL Editor:
-- update public.profiles set role='admin' where id=(select id from auth.users where email='email-admin-anda');
