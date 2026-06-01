import { createBrowserClient } from "@supabase/ssr"
import { getSupabasePublicEnv } from "./env"

/** Client browser (admin login, ecc.) — usa solo chiavi pubbliche. */
export function createClient() {
  const { url, anonKey } = getSupabasePublicEnv()
  return createBrowserClient(url, anonKey)
}
