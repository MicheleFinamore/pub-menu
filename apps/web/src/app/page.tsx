import { listVenues } from "@pub/db"
import Link from "next/link"

export default async function Home() {
  let venues: Awaited<ReturnType<typeof listVenues>> = []
  let error: string | null = null

  try {
    venues = await listVenues()
  } catch (e) {
    error = e instanceof Error ? e.message : "Connessione al database fallita"
  }

  return (
    <main className="mx-auto flex min-h-screen max-w-lg flex-col gap-6 p-8">
      <div>
        <h1 className="text-2xl font-semibold">pub-menu</h1>
        <p className="mt-2 text-muted-foreground">
          Connessione a Supabase Cloud (senza Docker).
        </p>
      </div>

      {error ? (
        <section className="rounded-lg border border-destructive/40 bg-destructive/5 p-4 text-sm">
          <p className="font-medium text-destructive">Database non raggiungibile</p>
          <p className="mt-2 text-muted-foreground">{error}</p>
          <p className="mt-3 text-muted-foreground">
            Inserisci le chiavi in{" "}
            <code className="rounded bg-muted px-1">apps/web/.env.local</code>{" "}
            (vedi <code className="rounded bg-muted px-1">.env.example</code>)
            e applica lo schema da{" "}
            <code className="rounded bg-muted px-1">
              supabase/migrations/20240101000000_init.sql
            </code>{" "}
            nel SQL Editor della dashboard.
          </p>
        </section>
      ) : (
        <section className="rounded-lg border p-4">
          <p className="text-sm text-muted-foreground">
            Connessione OK — {venues.length} locale/i in{" "}
            <code className="rounded bg-muted px-1">venues</code>
          </p>
          {venues.length > 0 ? (
            <ul className="mt-3 space-y-2 text-sm">
              {venues.map((v) => (
                <li key={v.id}>
                  <Link
                    href={`/${v.slug}/menu`}
                    className="font-medium underline-offset-4 hover:underline"
                  >
                    {v.name}
                  </Link>{" "}
                  <span className="text-muted-foreground">/{v.slug}/menu</span>
                </li>
              ))}
            </ul>
          ) : (
            <p className="mt-3 text-sm text-muted-foreground">
              Nessun locale ancora. Esegui il seed o inserisci righe in{" "}
              <code className="rounded bg-muted px-1">venues</code>.
            </p>
          )}
        </section>
      )}

      <p className="text-sm text-muted-foreground">
        Test API:{" "}
        <Link href="/api/db-check" className="underline-offset-4 hover:underline">
          /api/db-check
        </Link>
      </p>
    </main>
  )
}
