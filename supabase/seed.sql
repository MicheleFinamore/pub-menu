-- Demo venue for local development (slug: demo-pub)

insert into public.venues (id, slug, name)
values (
  'a0000000-0000-4000-8000-000000000001',
  'demo-pub',
  'Demo Pub'
)
on conflict (slug) do nothing;

insert into public.app_settings (venue_id, key, value)
values
  ('a0000000-0000-4000-8000-000000000001', 'site.title', 'Demo Pub'),
  ('a0000000-0000-4000-8000-000000000001', 'menu.footer_text', 'Buon appetito!'),
  ('a0000000-0000-4000-8000-000000000001', 'menu.hero_tagline', 'Il nostro menu')
on conflict (venue_id, key) do nothing;

insert into public.categories (id, venue_id, slug, icon, sort_order, is_active)
values (
  'b0000000-0000-4000-8000-000000000001',
  'a0000000-0000-4000-8000-000000000001',
  'birre',
  'beer',
  0,
  true
)
on conflict (venue_id, slug) do nothing;

insert into public.category_labels (category_id, locale, name)
values ('b0000000-0000-4000-8000-000000000001', 'it', 'Birre')
on conflict (category_id, locale) do nothing;

insert into public.products (
  id, venue_id, category_id, slug, image_url, sort_order, is_active
)
values (
  'c0000000-0000-4000-8000-000000000001',
  'a0000000-0000-4000-8000-000000000001',
  'b0000000-0000-4000-8000-000000000001',
  'lager-demo',
  null,
  0,
  true
)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values (
  'c0000000-0000-4000-8000-000000000001',
  'it',
  'Lager della casa',
  'Birra chiara, fresca e leggera.'
)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values
  ('c0000000-0000-4000-8000-000000000001', '0.4L', 4.50, 0, true),
  ('c0000000-0000-4000-8000-000000000001', '0.6L', 6.00, 1, true);

insert into public.tags (id, venue_id, color)
values (
  'd0000000-0000-4000-8000-000000000001',
  'a0000000-0000-4000-8000-000000000001',
  '#16a34a'
)
on conflict do nothing;

insert into public.tag_labels (tag_id, locale, name)
values ('d0000000-0000-4000-8000-000000000001', 'it', 'Novità')
on conflict (tag_id, locale) do nothing;

insert into public.product_tags (product_id, tag_id)
values (
  'c0000000-0000-4000-8000-000000000001',
  'd0000000-0000-4000-8000-000000000001'
)
on conflict do nothing;
