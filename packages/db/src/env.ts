function required(name: string): string {
  const value = process.env[name]?.trim()
  if (!value) {
    throw new Error(
      `Variabile d'ambiente mancante: ${name}. Copia apps/web/.env.example in apps/web/.env.local e inserisci le chiavi da Supabase Dashboard → Project Settings → API.`
    )
  }
  return value
}

/** Chiavi pubbliche (browser + server). Da Supabase Dashboard → API. */
export function getSupabasePublicEnv() {
  return {
    url: required("NEXT_PUBLIC_SUPABASE_URL"),
    anonKey: required("NEXT_PUBLIC_SUPABASE_ANON_KEY"),
  }
}

/** Service role — solo server, mai esporre al client. */
export function getSupabaseServiceRoleKey() {
  return required("SUPABASE_SERVICE_ROLE_KEY")
}
