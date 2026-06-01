import { createClient } from "./client"

export type VenueRow = {
  id: string
  slug: string
  name: string
}

/** Verifica connessione e permessi di lettura sulla tabella venues. */
export async function checkDatabaseConnection() {
  const supabase = createClient()
  const { error } = await supabase.from("venues").select("id", { head: true })

  if (error) {
    throw new Error(error.message)
  }

  return { ok: true as const }
}

/** Elenco locali (pub) — query di esempio. */
export async function listVenues(): Promise<VenueRow[]> {
  const supabase = createClient()
  const { data, error } = await supabase
    .from("venues")
    .select("id, slug, name")
    .order("name")

  if (error) {
    throw new Error(error.message)
  }

  return data ?? []
}
