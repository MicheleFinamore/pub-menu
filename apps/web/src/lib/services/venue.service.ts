import { createClient } from "@/lib/supabase/server"

export async function getVenueBySlug(
  slug: string
): Promise<{ id: string; slug: string; name: string } | null> {
  const supabase = await createClient()

  const { data, error } = await supabase
    .from("venues")
    .select("id, slug, name")
    .eq("slug", slug)
    .single()

  if (error) {
    if (error.code === "PGRST116") return null
    throw new Error(error.message)
  }

  return data
}

export async function getVenueSettings(
  venueId: string
): Promise<Record<string, string>> {
  const supabase = await createClient()

  const { data, error } = await supabase
    .from("app_settings")
    .select("key, value")
    .eq("venue_id", venueId)

  if (error) throw new Error(error.message)

  return Object.fromEntries((data ?? []).map((row) => [row.key, row.value]))
}
