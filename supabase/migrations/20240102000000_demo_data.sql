-- =============================================================================
-- Demo data for venue: demo-pub (a0000000-0000-4000-8000-000000000001)
-- Beer Shop & Pub — realistic menu seed
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. MISSING CONSTRAINTS (needed for ON CONFLICT below)
-- -----------------------------------------------------------------------------

do $$ begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'product_variants_product_id_size_label_key'
  ) then
    alter table public.product_variants
      add constraint product_variants_product_id_size_label_key
      unique (product_id, size_label);
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- 1. APP SETTINGS
-- -----------------------------------------------------------------------------
insert into public.app_settings (venue_id, key, value)
values
  ('a0000000-0000-4000-8000-000000000001', 'site.title',          'Beer Shop & Pub'),
  ('a0000000-0000-4000-8000-000000000001', 'menu.hero_tagline',   'Il menù, servito bene.'),
  ('a0000000-0000-4000-8000-000000000001', 'menu.hero_subtitle',  'Birre artigianali alla spina, fritti, pinse romane e piatti della casa.'),
  ('a0000000-0000-4000-8000-000000000001', 'menu.footer_text',    'Siamo aperti tutti i giorni dalle 17:00 — Seguici su Instagram @beershoppub'),
  ('a0000000-0000-4000-8000-000000000001', 'header.admin_label',  'ADMIN')
on conflict (venue_id, key) do update set value = excluded.value;

-- -----------------------------------------------------------------------------
-- 2. CATEGORIES
-- -----------------------------------------------------------------------------

-- 2a. Birre alla Spina (already exists as 'birre', sort_order 0)
-- update the label name
insert into public.category_labels (category_id, locale, name)
values ('b0000000-0000-4000-8000-000000000001', 'it', 'Birre alla Spina')
on conflict (category_id, locale) do update set name = excluded.name;

-- 2b. Fritti & Sfizi
insert into public.categories (id, venue_id, slug, icon, sort_order, is_active)
values ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'fritti-sfizi', 'flame', 1, true)
on conflict (venue_id, slug) do nothing;

insert into public.category_labels (category_id, locale, name)
values ('b0000000-0000-4000-8000-000000000002', 'it', 'Fritti & Sfizi')
on conflict (category_id, locale) do update set name = excluded.name;

-- 2c. Pinse
insert into public.categories (id, venue_id, slug, icon, sort_order, is_active)
values ('b0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', 'pinse', 'pizza', 2, true)
on conflict (venue_id, slug) do nothing;

insert into public.category_labels (category_id, locale, name)
values ('b0000000-0000-4000-8000-000000000003', 'it', 'Pinse')
on conflict (category_id, locale) do update set name = excluded.name;

-- 2d. Piatti
insert into public.categories (id, venue_id, slug, icon, sort_order, is_active)
values ('b0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000001', 'piatti', 'utensils', 3, true)
on conflict (venue_id, slug) do nothing;

insert into public.category_labels (category_id, locale, name)
values ('b0000000-0000-4000-8000-000000000004', 'it', 'Piatti')
on conflict (category_id, locale) do update set name = excluded.name;

-- -----------------------------------------------------------------------------
-- 3. TAGS
-- -----------------------------------------------------------------------------

-- Novità: d0000000-0000-4000-8000-000000000001 (existing, #16a34a)

-- Stagionale
insert into public.tags (id, venue_id, color)
values ('d0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', '#f97316')
on conflict do nothing;

insert into public.tag_labels (tag_id, locale, name)
values ('d0000000-0000-4000-8000-000000000002', 'it', 'Stagionale')
on conflict (tag_id, locale) do nothing;

-- Consigliato
insert into public.tags (id, venue_id, color)
values ('d0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', '#eab308')
on conflict do nothing;

insert into public.tag_labels (tag_id, locale, name)
values ('d0000000-0000-4000-8000-000000000003', 'it', 'Consigliato')
on conflict (tag_id, locale) do nothing;

-- Piccante
insert into public.tags (id, venue_id, color)
values ('d0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000001', '#dc2626')
on conflict do nothing;

insert into public.tag_labels (tag_id, locale, name)
values ('d0000000-0000-4000-8000-000000000004', 'it', 'Piccante')
on conflict (tag_id, locale) do nothing;

-- PATATINE (sub-category tag for fritti)
insert into public.tags (id, venue_id, color)
values ('d0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000001', '#94a3b8')
on conflict do nothing;

insert into public.tag_labels (tag_id, locale, name)
values ('d0000000-0000-4000-8000-000000000005', 'it', 'PATATINE')
on conflict (tag_id, locale) do nothing;

-- CROCCHETTONI ARTIGIANALI (sub-category tag for fritti)
insert into public.tags (id, venue_id, color)
values ('d0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000001', '#94a3b8')
on conflict do nothing;

insert into public.tag_labels (tag_id, locale, name)
values ('d0000000-0000-4000-8000-000000000006', 'it', 'CROCCHETTONI ARTIGIANALI')
on conflict (tag_id, locale) do nothing;

-- -----------------------------------------------------------------------------
-- 4. PRODUCTS — Birre alla Spina
-- -----------------------------------------------------------------------------

-- 4a. Stria — Lager 4.8% · Toccalmatto, IT
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'stria', null, 1, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values (
  'c0000000-0000-4000-8000-000000000002', 'it',
  'Stria — Lager 4.8% · Toccalmatto, IT',
  'Fresca e leggera, ispirazione tedesca con luppoli nobili e malti d''orzo. Colore dorato pallido, schiuma bianca fine.'
)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values
  ('c0000000-0000-4000-8000-000000000002', '0,2cl',  3.00, 0, true),
  ('c0000000-0000-4000-8000-000000000002', '0,4cl',  5.00, 1, true),
  ('c0000000-0000-4000-8000-000000000002', '1L',    10.00, 2, true)
on conflict (product_id, size_label) do nothing;

-- Tag: Novità
insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000002', 'd0000000-0000-4000-8000-000000000001')
on conflict do nothing;

-- 4b. Call Me Welly — Bitter 4.2% · 50&50, IT
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'call-me-welly', null, 2, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values (
  'c0000000-0000-4000-8000-000000000003', 'it',
  'Call Me Welly — Bitter 4.2% · 50&50, IT',
  'Ramato intenso, leggermente velata. Note erbacee, malto e frutta secca, finale secco e amaro.'
)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values
  ('c0000000-0000-4000-8000-000000000003', '0,2cl', 3.50, 0, true),
  ('c0000000-0000-4000-8000-000000000003', '0,4cl', 6.00, 1, true)
on conflict (product_id, size_label) do nothing;

-- 4c. Scorretta — Bock 6% · La Gramigna, IT
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'scorretta', null, 3, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values (
  'c0000000-0000-4000-8000-000000000004', 'it',
  'Scorretta — Bock 6% · La Gramigna, IT',
  'Ramato, limpida, schiuma persistente. Note di caramello e biscotto, luppolatura erbacea e floreale.'
)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values
  ('c0000000-0000-4000-8000-000000000004', '0,2cl', 4.00, 0, true),
  ('c0000000-0000-4000-8000-000000000004', '0,4cl', 7.00, 1, true)
on conflict (product_id, size_label) do nothing;

-- 4d. Super Strong Lager — 8.4%
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'super-strong-lager', null, 4, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values (
  'c0000000-0000-4000-8000-000000000005', 'it',
  'Super Strong Lager — Strong Lager 8.4%',
  'Corposa e intensa, beverina con finale alleggerito.'
)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values
  ('c0000000-0000-4000-8000-000000000005', '0,2cl', 4.00, 0, true),
  ('c0000000-0000-4000-8000-000000000005', '0,4cl', 7.00, 1, true)
on conflict (product_id, size_label) do nothing;

-- -----------------------------------------------------------------------------
-- 5. PRODUCTS — Fritti & Sfizi
-- -----------------------------------------------------------------------------

-- 5a. Patatine fritte
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'patatine-fritte', null, 0, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000006', 'it', 'Patatine fritte', null)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000006', 'porzione', 4.00, 0, true)
on conflict (product_id, size_label) do nothing;

insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000006', 'd0000000-0000-4000-8000-000000000005')
on conflict do nothing;

-- 5b. Patatine Bacon & Cheddar
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000007', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'patatine-bacon-cheddar', null, 1, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000007', 'it', 'Patatine Bacon & Cheddar', null)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000007', 'porzione', 5.50, 0, true)
on conflict (product_id, size_label) do nothing;

insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000007', 'd0000000-0000-4000-8000-000000000005')
on conflict do nothing;

-- 5c. Patatine dolci con crema ai 4 formaggi
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000008', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'patatine-dolci-crema-4-formaggi', null, 2, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000008', 'it', 'Patatine dolci con crema ai 4 formaggi', null)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000008', 'porzione', 5.50, 0, true)
on conflict (product_id, size_label) do nothing;

insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000008', 'd0000000-0000-4000-8000-000000000005')
on conflict do nothing;

-- 5d. Patatine fritte con Würstel
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000009', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'patatine-wurstel', null, 3, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000009', 'it', 'Patatine fritte con Würstel', null)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000009', 'porzione', 4.50, 0, true)
on conflict (product_id, size_label) do nothing;

insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000009', 'd0000000-0000-4000-8000-000000000005')
on conflict do nothing;

-- 5e. Patatine Twister
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000010', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'patatine-twister', null, 4, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000010', 'it', 'Patatine Twister', null)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000010', 'porzione', 5.00, 0, true)
on conflict (product_id, size_label) do nothing;

insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000010', 'd0000000-0000-4000-8000-000000000005')
on conflict do nothing;

-- 5f. Patatine Cross
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000011', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'patatine-cross', null, 5, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000011', 'it', 'Patatine Cross', null)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000011', 'porzione', 5.00, 0, true)
on conflict (product_id, size_label) do nothing;

insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000011', 'd0000000-0000-4000-8000-000000000005')
on conflict do nothing;

-- 5g. Crocchettoni di patate al formaggio
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000012', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'crocchettoni-formaggio', null, 6, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000012', 'it', 'Crocchettoni di patate al formaggio', null)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000012', 'porzione', 5.00, 0, true)
on conflict (product_id, size_label) do nothing;

insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000012', 'd0000000-0000-4000-8000-000000000006')
on conflict do nothing;

-- 5h. Crocchettoni di patate al ragù
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000013', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'crocchettoni-ragu', null, 7, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000013', 'it', 'Crocchettoni di patate al ragù', null)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000013', 'porzione', 5.50, 0, true)
on conflict (product_id, size_label) do nothing;

insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000013', 'd0000000-0000-4000-8000-000000000006')
on conflict do nothing;

-- 5i. Mozzarella in carrozza (x2)
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000014', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'mozzarella-in-carrozza', null, 8, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000014', 'it', 'Mozzarella in carrozza (x2)', null)
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000014', 'porzione', 4.00, 0, true)
on conflict (product_id, size_label) do nothing;

-- -----------------------------------------------------------------------------
-- 6. PRODUCTS — Pinse
-- -----------------------------------------------------------------------------

-- 6a. Pinsa Margherita
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000015', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000003', 'pinsa-margherita', null, 0, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000015', 'it', 'Pinsa Margherita', 'Pomodoro, mozzarella, basilico.')
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000015', 'intero', 8.00, 0, true)
on conflict (product_id, size_label) do nothing;

-- Tag: Stagionale
insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000015', 'd0000000-0000-4000-8000-000000000002')
on conflict do nothing;

-- 6b. Pinsa Prosciutto e Funghi
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000016', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000003', 'pinsa-prosciutto-funghi', null, 1, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000016', 'it', 'Pinsa Prosciutto e Funghi', 'Prosciutto cotto, funghi, mozzarella.')
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000016', 'intero', 10.00, 0, true)
on conflict (product_id, size_label) do nothing;

-- 6c. Pinsa Diavola
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000017', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000003', 'pinsa-diavola', null, 2, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000017', 'it', 'Pinsa Diavola', 'Salame piccante, mozzarella.')
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000017', 'intero', 10.00, 0, true)
on conflict (product_id, size_label) do nothing;

-- Tag: Piccante
insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000017', 'd0000000-0000-4000-8000-000000000004')
on conflict do nothing;

-- 6d. Pinsa del Pub
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000018', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000003', 'pinsa-del-pub', null, 3, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000018', 'it', 'Pinsa del Pub', 'Prosciutto cotto, gorgonzola, noci.')
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000018', 'intero', 12.00, 0, true)
on conflict (product_id, size_label) do nothing;

-- Tag: Consigliato
insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000018', 'd0000000-0000-4000-8000-000000000003')
on conflict do nothing;

-- 6e. Pinsa Vegetariana
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000019', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000003', 'pinsa-vegetariana', null, 4, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000019', 'it', 'Pinsa Vegetariana', 'Verdure grigliate, provola.')
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000019', 'intero', 10.00, 0, true)
on conflict (product_id, size_label) do nothing;

-- -----------------------------------------------------------------------------
-- 7. PRODUCTS — Piatti
-- -----------------------------------------------------------------------------

-- 7a. Tagliere Misto
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000020', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000004', 'tagliere-misto', null, 0, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000020', 'it', 'Tagliere Misto', 'Formaggi e salumi selezionati.')
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000020', '€', 14.00, 0, true)
on conflict (product_id, size_label) do nothing;

-- 7b. Hot Dog del Pub
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000021', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000004', 'hot-dog-del-pub', null, 1, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000021', 'it', 'Hot Dog del Pub', 'Würstel artigianale, senape, cipolla caramellata.')
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000021', '€', 9.00, 0, true)
on conflict (product_id, size_label) do nothing;

-- 7c. Burger del Pub
insert into public.products (id, venue_id, category_id, slug, image_url, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000022', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000004', 'burger-del-pub', null, 2, true)
on conflict (venue_id, slug) do nothing;

insert into public.product_labels (product_id, locale, name, description)
values ('c0000000-0000-4000-8000-000000000022', 'it', 'Burger del Pub', '180g manzo, cheddar, lattuga, pomodoro.')
on conflict (product_id, locale) do nothing;

insert into public.product_variants (product_id, size_label, price, sort_order, is_active)
values ('c0000000-0000-4000-8000-000000000022', '€', 13.00, 0, true)
on conflict (product_id, size_label) do nothing;

-- Tag: Consigliato
insert into public.product_tags (product_id, tag_id)
values ('c0000000-0000-4000-8000-000000000022', 'd0000000-0000-4000-8000-000000000003')
on conflict do nothing;
