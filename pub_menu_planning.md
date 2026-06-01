```markdown
# pub-menu — Project Planning & Starting Point

> Documento di contesto per Cursor. Leggilo integralmente prima di generare qualsiasi codice.
> Aggiornalo man mano che il progetto evolve.

---

## Contesto del progetto

Applicazione web per la gestione e visualizzazione di menu digitali per locali (pub, bar, ristoranti).
Architettura **multi-tenant**: un'unica codebase serve N locali, ognuno isolato con il proprio slug, dati e admin.

### Utenti e ruoli

| Ruolo | Superficie | Descrizione |
|---|---|---|
| **Cliente** | `/{venue-slug}/menu` | Visualizza il menu pubblico, nessun login |
| **Admin** | `/admin/`* | Gestisce categorie, prodotti, prezzi, immagini, impostazioni del proprio locale |

---

## Stack tecnologico

| Layer | Tecnologia | Motivo |
|---|---|---|
| Frontend + API | **Next.js 15** (App Router) | ISR nativo, Server Actions, unico deploy |
| Database | **Supabase** (PostgreSQL) | RLS multi-tenant, Auth, Storage, Realtime |
| Auth | **Supabase Auth** (email + password) | Integrazione nativa, JWT con claims per RLS |
| UI Admin | **shadcn/ui** + **Tailwind v4** | Componenti accessibili, headless |
| Drag & Drop | **@dnd-kit** | Riordinamento categorie e prodotti |
| Monorepo | **pnpm workspaces** + **Turborepo** | Hoisting, cache build, script unificati |
| Deploy | **Vercel** | ISR + revalidation nativa per Next.js |
| Immagini | **Supabase Storage** | Bucket CDN pubblico per foto prodotti |

> **Nessun backend separato.** Le Route Handlers di Next.js (`app/api/`) fungono da API layer,
> chiamando Supabase server-side con la service role key. Il client non vede mai la chiave segreta.

---

## Struttura del monorepo

```
pub-menu/
├── apps/
│   └── web/                        # Next.js 15 — menu pubblico + admin panel
│       ├── src/
│       │   ├── app/
│       │   │   ├── [venue]/
│       │   │   │   └── menu/       # Menu pubblico (SSR + ISR, no auth)
│       │   │   ├── admin/          # Pannello admin (authed, middleware protetto)
│       │   │   │   ├── login/
│       │   │   │   ├── categories/
│       │   │   │   ├── products/
│       │   │   │   ├── tags/
│       │   │   │   └── settings/
│       │   │   └── api/
│       │   │       ├── [venue]/menu/route.ts   # GET — payload completo menu
│       │   │       └── revalidate/route.ts     # POST — cache invalidation
│       │   ├── components/
│       │   │   ├── menu/           # Componenti menu pubblico
│       │   │   └── admin/          # Componenti admin panel
│       │   ├── lib/
│       │   │   ├── supabase/
│       │   │   │   ├── server.ts   # Client SSR (cookies)
│       │   │   │   └── client.ts   # Client browser
│       │   │   └── utils.ts
│       │   └── middleware.ts       # Protezione route /admin/*
│       ├── .env.local
│       └── package.json
├── packages/
│   ├── db/                         # @pub/db — client Supabase tipizzato + query helpers
│   │   └── src/
│   │       ├── index.ts
│   │       ├── client.ts
│   │       ├── types.ts            # Generato da: supabase gen types typescript
│   │       └── queries.ts          # Query riutilizzabili (getMenuByVenue, ecc.)
│   └── ui/                         # @pub/ui — componenti shadcn condivisi (opzionale)
├── supabase/
│   ├── migrations/
│   │   └── 20240101000000_init.sql
│   └── seed.sql
├── pnpm-workspace.yaml
├── turbo.json
└── package.json                    # Root — solo script e devDependencies
```

---

## Schema database (PostgreSQL / Supabase)

### Logica multi-tenant

Ogni riga con dati di un locale contiene `venue_id`. Le RLS policy usano una funzione helper
`is_venue_admin(venue_id)` che controlla se `auth.uid()` è presente in `venue_users`.
Il cliente (non autenticato) può leggere solo righe con `is_active = true` via policy pubblica.

### Tabelle

```sql
-- ROOT ENTITY
venues (id, slug, name, created_at)

-- CHI GESTISCE QUALE LOCALE
venue_users (venue_id, user_id, role)

-- IMPOSTAZIONI GLOBALI TESTUALI (chiave→valore per venue)
-- es: site.title, menu.footer_text, menu.hero_tagline
app_settings (id, venue_id, key, value)

-- CATEGORIE
categories      (id, venue_id, slug, icon, sort_order, is_active)
category_labels (id, category_id, locale, name)         -- testo separato per i18n futuro

-- TAG / BADGE sui prodotti
tags       (id, venue_id, color)
tag_labels (id, tag_id, locale, name)

-- PRODOTTI
products        (id, venue_id, category_id, slug, image_url, sort_order, is_active)
product_labels  (id, product_id, locale, name, description)

-- VARIANTI PREZZO (es. 0.4L / 0.6L, Piccola / Grande)
product_variants (id, product_id, size_label, price, sort_order, is_active)

-- RELAZIONE PRODOTTO ↔ TAG (many-to-many)
product_tags (product_id, tag_id)
```

### Perché le tabelle `*_labels`?

Separano il contenuto testuale dalla struttura dati. Con la colonna `locale` è possibile aggiungere
l'internazionalizzazione in futuro senza refactoring. Anche con una sola lingua (`it`), questo pattern
garantisce che **zero testo sia hardcoded nel codice**: tutto è modificabile via admin panel.

### RLS in breve

```sql
-- Lettura pubblica (clienti): solo righe is_active = true, nessun auth
-- Scrittura admin: solo se is_venue_admin(venue_id) = true
-- is_venue_admin() controlla venue_users con auth.uid()
```

---

## API Route principale: `GET /api/[venue]/menu`

È il cuore del sistema pubblico. Restituisce un **unico payload JSON** con tutto
il necessario per renderizzare il menu completo. Una sola richiesta HTTP al caricamento.

```typescript
// Struttura del payload restituito
{
  venue: { id, name, slug },
  settings: [{ key, value }],        // etichette globali
  categories: [
    {
      id, slug, icon, sort_order,
      category_labels: [{ name, locale }],
      products: [
        {
          id, slug, image_url, sort_order, is_active,
          product_labels: [{ name, description, locale }],
          product_variants: [{ id, size_label, price, sort_order }],
          product_tags: [
            { tags: { id, color, tag_labels: [{ name }] } }
          ]
        }
      ]
    }
  ]
}
```

Con `export const revalidate = 60` e header `Cache-Control: s-maxage=60, stale-while-revalidate=300`,
la pagina è statica per i clienti ma si aggiorna entro 60 secondi dopo ogni modifica admin.

---

## User Stories implementate

### Cliente (menu pubblico)

- **UC-01** Visualizza menu diviso per categorie (birre, cocktail, stuzzichini…)
- **UC-02** Vede nome, descrizione, foto e prezzo con varianti (piccola/media/grande)
- **UC-03** Interfaccia mobile-first, fluida, senza zoom o scroll orizzontale
- **UC-04** Menu si aggiorna in tempo reale dopo modifiche admin (ISR + opzionale Supabase Realtime)
- **UC-05** Etichette come "Novità", "Stagionale", "Senza glutine" sui prodotti

### Admin (pannello protetto)

- **UC-06** Login sicuro con email e password (Supabase Auth)
- **UC-07** CRUD categorie con nome, icona e ordine di visualizzazione
- **UC-08** CRUD prodotti con categoria, nome, descrizione, foto, stato attivo/inattivo
- **UC-09** Gestione varianti di prezzo (es. "0.4L: €4,50 / 0.6L: €6,00")
- **UC-10** Modifica etichette testuali globali dalla schermata "Impostazioni"
- **UC-11** Gestione tag/badge sui prodotti
- **UC-12** Drag-and-drop per riordinare categorie e prodotti
- **UC-13** Upload/sostituzione foto prodotto (Supabase Storage)
- **UC-14** Disattivazione temporanea prodotto (senza eliminazione)

---

## Fasi di sviluppo (ordine consigliato)

```
01 — Scaffolding monorepo (pnpm workspaces + Turborepo + Next.js 15)
02 — Schema SQL + migrations Supabase + RLS policies + Storage bucket
03 — Package condiviso @pub/db (tipi generati + client tipizzato)
04 — Client Supabase SSR-safe (server.ts + client.ts)
05 — Middleware auth (protezione /admin/*)
06 — API Route GET /api/[venue]/menu (payload aggregato + ISR)
07 — Menu pubblico frontend ([venue]/menu/page.tsx)
08 — Login admin (Supabase Auth)
09 — Admin panel — CRUD categorie, prodotti, varianti, tag, impostazioni
10 — Upload immagini (Supabase Storage)
11 — Cache revalidation al salvataggio admin
12 — (Opzionale) Supabase Realtime per aggiornamenti live sul menu
13 — Deploy Vercel + env vars + dominio custom
```

---

## Comandi di setup (da eseguire in ordine)

### 1. Root del monorepo

```bash
mkdir pub-menu && cd pub-menu
git init

# pnpm-workspace.yaml
echo 'packages:\n  - "apps/*"\n  - "packages/*"' > pnpm-workspace.yaml

# package.json root
cat > package.json << 'EOF'
{
  "name": "pub-menu",
  "private": true,
  "scripts": {
    "dev": "turbo run dev",
    "build": "turbo run build",
    "db:types": "supabase gen types typescript --local > packages/db/src/types.ts"
  },
  "devDependencies": {
    "turbo": "^2"
  }
}
EOF

# turbo.json
cat > turbo.json << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": { "dependsOn": ["^build"], "outputs": [".next/**", "dist/**"] },
    "dev":   { "persistent": true, "cache": false },
    "lint":  {}
  }
}
EOF

pnpm install
```

### 2. App Next.js

```bash
mkdir apps && cd apps
pnpm create next-app@latest web \
  --typescript --tailwind --eslint --app --src-dir \
  --import-alias "@/*"

cd web

# Dipendenze runtime
pnpm add @supabase/supabase-js @supabase/ssr
pnpm add @tanstack/react-query
pnpm add lucide-react
pnpm add @dnd-kit/core @dnd-kit/sortable @dnd-kit/utilities
pnpm add sonner
pnpm add zod

# shadcn/ui
pnpm dlx shadcn@latest init
# Scegli: Default style, Zinc, CSS variables: yes

pnpm dlx shadcn@latest add button input label card table dialog \
  sheet form select badge switch tabs dropdown-menu
```

### 3. Package @pub/db

```bash
cd ../../
mkdir -p packages/db/src

cat > packages/db/package.json << 'EOF'
{
  "name": "@pub/db",
  "version": "0.0.1",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "dependencies": {
    "@supabase/supabase-js": "^2"
  }
}
EOF
```

In `packages/db/src/index.ts`:
```typescript
export { createClient } from "./client"
export type { Database } from "./types"
export * from "./queries"
```

In `packages/db/src/client.ts`:
```typescript
import { createClient as _create } from "@supabase/supabase-js"
import type { Database } from "./types"

export const createClient = () =>
  _create<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
```

```bash
# Aggiungi @pub/db come dipendenza di apps/web
cd apps/web
pnpm add @pub/db --workspace
```

### 4. Supabase

```bash
npm install -g supabase
# dalla root del monorepo:
supabase init
supabase start                  # richiede Docker — salva le chiavi nell'output
supabase db push                # applica le migrations
supabase gen types typescript --local > packages/db/src/types.ts
```

### 5. Variabili d'ambiente (`apps/web/.env.local`)

```env
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=<da supabase start>
SUPABASE_SERVICE_ROLE_KEY=<da supabase start>
```

### 6. Avvio in locale

```bash
# dalla root del monorepo
supabase start   # se non già attivo
pnpm dev
```

---

## Comandi ricorrenti

```bash
# Dopo ogni modifica allo schema SQL
supabase gen types typescript --local > packages/db/src/types.ts

# Nuova migration
supabase migration new <nome_migration>

# Applicare migrations in locale
supabase db push

# Applicare migrations in produzione (dopo supabase link)
supabase link --project-ref <project-ref>
supabase db push --linked

# Build completo monorepo
pnpm build

# Aggiungere componente shadcn
pnpm --filter web dlx shadcn@latest add <component>
```

---

## Note architetturali importanti

### Perché non un backend separato (Fastify/Express)?

Con Supabase, le join complesse si fanno in una sola chiamata client:
```typescript
supabase.from("categories").select(`
  *, category_labels(*),
  products(*, product_labels(*), product_variants(*), product_tags(tags(*, tag_labels(*))))
`)
```
Le Next.js Route Handlers (`app/api/`) fungono da API layer sicuro lato server.
Un backend separato aggiunge overhead di deploy e manutenzione senza vantaggi concreti
per questo caso d'uso. Aggiungilo solo se in futuro servono: integrazioni POS, pagamenti,
logica di business complessa non gestibile in Route Handlers.

### Perché RLS invece di filtrare per venue_id nel codice?

Supabase applica le policy a livello database — anche se una Route Handler avesse un bug
e dimenticasse il filtro `venue_id`, il DB rifiuterebbe comunque le righe di altri tenant.
È un secondo livello di protezione automatico.

### ISR vs Realtime: quando usare cosa?

- **ISR** (`revalidate = 60`): sufficiente per il 99% dei casi. Il menu si aggiorna
  entro 60 secondi dopo ogni salvataggio admin. Zero infrastruttura extra.
- **Supabase Realtime**: utile se vuoi propagazione istantanea (< 1s). Aggiunge
  una WebSocket connection sul client. Implementa solo se il cliente lo richiede esplicitamente.

### Immagini prodotto

Vanno su **Supabase Storage** (bucket `product-images`, pubblico).
Il campo `products.image_url` salva l'URL pubblico del file.
Non salvare mai immagini come base64 nel database.

---

## TODO iniziale (priorità)

- [ ] Creare il progetto su Supabase Cloud (https://supabase.com/dashboard)
- [ ] Eseguire i comandi di setup nell'ordine indicato
- [ ] Scrivere `supabase/migrations/20240101000000_init.sql` con lo schema completo
- [ ] Implementare `GET /api/[venue]/menu` e testarlo con dati seed
- [ ] Costruire la pagina menu pubblico `[venue]/menu/page.tsx`
- [ ] Implementare login admin e middleware
- [ ] Costruire il CRUD admin partendo dalle categorie

---

*Ultimo aggiornamento: giugno 2026*

```

