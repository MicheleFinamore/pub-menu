import { createClient as createSupabaseClient } from "@supabase/supabase-js"
import { getSupabasePublicEnv, getSupabaseServiceRoleKey } from "./env"
import type { Database } from "./types"

/** Client con service role — solo Route Handlers / Server Actions. Bypassa RLS. */
export function createAdminClient() {
  const { url } = getSupabasePublicEnv()
  return createSupabaseClient<Database>(url, getSupabaseServiceRoleKey(), {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  })
}
