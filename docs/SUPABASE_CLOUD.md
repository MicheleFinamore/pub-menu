# Supabase Cloud (senza Docker)

## 1. Crea il progetto

1. Vai su [Supabase Dashboard](https://supabase.com/dashboard)
2. **New project** → scegli nome, password DB e regione
3. Attendi che il progetto sia pronto

## 2. Chiavi API → `.env.local`

Dashboard → **Project Settings** → **API**:

| Dashboard | Variabile in `apps/web/.env.local` |
|-----------|----------------------------------|
| Project URL | `NEXT_PUBLIC_SUPABASE_URL` |
| anon public | `NEXT_PUBLIC_SUPABASE_ANON_KEY` |
| service_role | `SUPABASE_SERVICE_ROLE_KEY` |

```bash
cp apps/web/.env.example apps/web/.env.local
# Compila i tre valori nel file
```

> La `service_role` bypassa RLS: usala solo in codice server (Route Handlers, Server Actions), mai nel browser.

## 3. Applica lo schema

**Opzione A — SQL Editor (più semplice)**

1. Dashboard → **SQL Editor** → New query
2. Incolla il contenuto di `supabase/migrations/20240101000000_init.sql` ed esegui
3. (Opzionale) Incolla ed esegui anche `supabase/seed.sql` per il locale demo `demo-pub`

**Opzione B — Supabase CLI collegata al cloud**

```bash
npx supabase login
npx supabase link --project-ref <TUO_PROJECT_REF>
npx supabase db push
```

Il `project-ref` è nella URL della dashboard: `https://supabase.com/dashboard/project/<project-ref>`.

## 4. Tipi TypeScript (opzionale)

Dopo `supabase link`:

```bash
pnpm db:types
```

## 5. Verifica

```bash
pnpm dev
```

- Home: http://localhost:3000 — elenco `venues` se la connessione funziona
- API: http://localhost:3000/api/db-check

## Client nel codice

```typescript
import { createClient, listVenues } from "@pub/db"

const venues = await listVenues()
```

- **Browser / Server Components con sessione**: `apps/web/src/lib/supabase/client.ts` o `server.ts` (`@supabase/ssr`)
- **Server con privilegi elevati**: `createAdminClient()` da `@pub/db` (service role)
