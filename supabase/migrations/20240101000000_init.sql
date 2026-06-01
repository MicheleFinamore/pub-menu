-- pub-menu initial schema: multi-tenant menu + RLS

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table public.venues (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  created_at timestamptz not null default now()
);

create table public.venue_users (
  venue_id uuid not null references public.venues (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role text not null default 'admin' check (role in ('admin', 'owner')),
  primary key (venue_id, user_id)
);

create table public.app_settings (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues (id) on delete cascade,
  key text not null,
  value text not null,
  unique (venue_id, key)
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues (id) on delete cascade,
  slug text not null,
  icon text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  unique (venue_id, slug)
);

create table public.category_labels (
  id uuid primary key default gen_random_uuid(),
  category_id uuid not null references public.categories (id) on delete cascade,
  locale text not null default 'it',
  name text not null,
  unique (category_id, locale)
);

create table public.tags (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues (id) on delete cascade,
  color text not null default '#64748b'
);

create table public.tag_labels (
  id uuid primary key default gen_random_uuid(),
  tag_id uuid not null references public.tags (id) on delete cascade,
  locale text not null default 'it',
  name text not null,
  unique (tag_id, locale)
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues (id) on delete cascade,
  category_id uuid not null references public.categories (id) on delete cascade,
  slug text not null,
  image_url text,
  sort_order int not null default 0,
  is_active boolean not null default true,
  unique (venue_id, slug)
);

create table public.product_labels (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products (id) on delete cascade,
  locale text not null default 'it',
  name text not null,
  description text,
  unique (product_id, locale)
);

create table public.product_variants (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products (id) on delete cascade,
  size_label text not null,
  price numeric(10, 2) not null,
  sort_order int not null default 0,
  is_active boolean not null default true
);

create table public.product_tags (
  product_id uuid not null references public.products (id) on delete cascade,
  tag_id uuid not null references public.tags (id) on delete cascade,
  primary key (product_id, tag_id)
);

create index categories_venue_id_idx on public.categories (venue_id);
create index products_venue_id_idx on public.products (venue_id);
create index products_category_id_idx on public.products (category_id);
create index tags_venue_id_idx on public.tags (venue_id);

-- ---------------------------------------------------------------------------
-- RLS helper
-- ---------------------------------------------------------------------------

create or replace function public.is_venue_admin(check_venue_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from public.venue_users
    where venue_id = check_venue_id
      and user_id = auth.uid()
  );
$$;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.venues enable row level security;
alter table public.venue_users enable row level security;
alter table public.app_settings enable row level security;
alter table public.categories enable row level security;
alter table public.category_labels enable row level security;
alter table public.tags enable row level security;
alter table public.tag_labels enable row level security;
alter table public.products enable row level security;
alter table public.product_labels enable row level security;
alter table public.product_variants enable row level security;
alter table public.product_tags enable row level security;

-- venues
create policy "venues_public_read"
  on public.venues for select
  using (true);

create policy "venues_admin_write"
  on public.venues for all
  using (public.is_venue_admin(id))
  with check (public.is_venue_admin(id));

-- venue_users
create policy "venue_users_admin_read"
  on public.venue_users for select
  using (public.is_venue_admin(venue_id) or user_id = auth.uid());

create policy "venue_users_admin_write"
  on public.venue_users for all
  using (public.is_venue_admin(venue_id))
  with check (public.is_venue_admin(venue_id));

-- app_settings
create policy "app_settings_public_read"
  on public.app_settings for select
  using (true);

create policy "app_settings_admin_write"
  on public.app_settings for all
  using (public.is_venue_admin(venue_id))
  with check (public.is_venue_admin(venue_id));

-- categories
create policy "categories_public_read"
  on public.categories for select
  using (is_active = true or public.is_venue_admin(venue_id));

create policy "categories_admin_write"
  on public.categories for all
  using (public.is_venue_admin(venue_id))
  with check (public.is_venue_admin(venue_id));

-- category_labels
create policy "category_labels_public_read"
  on public.category_labels for select
  using (
    exists (
      select 1 from public.categories c
      where c.id = category_id
        and (c.is_active = true or public.is_venue_admin(c.venue_id))
    )
  );

create policy "category_labels_admin_write"
  on public.category_labels for all
  using (
    exists (
      select 1 from public.categories c
      where c.id = category_id and public.is_venue_admin(c.venue_id)
    )
  )
  with check (
    exists (
      select 1 from public.categories c
      where c.id = category_id and public.is_venue_admin(c.venue_id)
    )
  );

-- tags
create policy "tags_public_read"
  on public.tags for select
  using (public.is_venue_admin(venue_id) or true);

create policy "tags_admin_write"
  on public.tags for all
  using (public.is_venue_admin(venue_id))
  with check (public.is_venue_admin(venue_id));

-- tag_labels
create policy "tag_labels_public_read"
  on public.tag_labels for select
  using (
    exists (
      select 1 from public.tags t
      where t.id = tag_id
    )
  );

create policy "tag_labels_admin_write"
  on public.tag_labels for all
  using (
    exists (
      select 1 from public.tags t
      where t.id = tag_id and public.is_venue_admin(t.venue_id)
    )
  )
  with check (
    exists (
      select 1 from public.tags t
      where t.id = tag_id and public.is_venue_admin(t.venue_id)
    )
  );

-- products
create policy "products_public_read"
  on public.products for select
  using (is_active = true or public.is_venue_admin(venue_id));

create policy "products_admin_write"
  on public.products for all
  using (public.is_venue_admin(venue_id))
  with check (public.is_venue_admin(venue_id));

-- product_labels
create policy "product_labels_public_read"
  on public.product_labels for select
  using (
    exists (
      select 1 from public.products p
      where p.id = product_id
        and (p.is_active = true or public.is_venue_admin(p.venue_id))
    )
  );

create policy "product_labels_admin_write"
  on public.product_labels for all
  using (
    exists (
      select 1 from public.products p
      where p.id = product_id and public.is_venue_admin(p.venue_id)
    )
  )
  with check (
    exists (
      select 1 from public.products p
      where p.id = product_id and public.is_venue_admin(p.venue_id)
    )
  );

-- product_variants
create policy "product_variants_public_read"
  on public.product_variants for select
  using (
    exists (
      select 1 from public.products p
      where p.id = product_id
        and (p.is_active = true or public.is_venue_admin(p.venue_id))
    )
    and is_active = true
  );

create policy "product_variants_admin_write"
  on public.product_variants for all
  using (
    exists (
      select 1 from public.products p
      where p.id = product_id and public.is_venue_admin(p.venue_id)
    )
  )
  with check (
    exists (
      select 1 from public.products p
      where p.id = product_id and public.is_venue_admin(p.venue_id)
    )
  );

-- product_tags
create policy "product_tags_public_read"
  on public.product_tags for select
  using (
    exists (
      select 1 from public.products p
      where p.id = product_id
        and (p.is_active = true or public.is_venue_admin(p.venue_id))
    )
  );

create policy "product_tags_admin_write"
  on public.product_tags for all
  using (
    exists (
      select 1 from public.products p
      where p.id = product_id and public.is_venue_admin(p.venue_id)
    )
  )
  with check (
    exists (
      select 1 from public.products p
      where p.id = product_id and public.is_venue_admin(p.venue_id)
    )
  );

-- ---------------------------------------------------------------------------
-- Storage: product images (public read, admin write)
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do nothing;

create policy "product_images_public_read"
  on storage.objects for select
  using (bucket_id = 'product-images');

create policy "product_images_admin_insert"
  on storage.objects for insert
  with check (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1] is not null
    and public.is_venue_admin(((storage.foldername(name))[1])::uuid)
  );

create policy "product_images_admin_update"
  on storage.objects for update
  using (
    bucket_id = 'product-images'
    and public.is_venue_admin(((storage.foldername(name))[1])::uuid)
  );

create policy "product_images_admin_delete"
  on storage.objects for delete
  using (
    bucket_id = 'product-images'
    and public.is_venue_admin(((storage.foldername(name))[1])::uuid)
  );
