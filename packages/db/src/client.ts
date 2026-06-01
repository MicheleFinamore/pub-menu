import { createClient as createSupabaseClient } from "@supabase/supabase-js"
import { getSupabasePublicEnv } from "./env"
import type { Database } from "./types"

/** Client Supabase con chiave anon (rispetta RLS). Usabile da server e, con le env NEXT_PUBLIC_*, dal browser. */
export function createClient() {
  const { url, anonKey } = getSupabasePublicEnv()
  return createSupabaseClient<Database>(url, anonKey)
}
