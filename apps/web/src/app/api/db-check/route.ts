import { checkDatabaseConnection, listVenues } from "@pub/db"
import { NextResponse } from "next/server"

export async function GET() {
  try {
    await checkDatabaseConnection()
    const venues = await listVenues()

    return NextResponse.json({
      ok: true,
      venueCount: venues.length,
      venues,
    })
  } catch (error) {
    const message =
      error instanceof Error ? error.message : "Errore sconosciuto"

    return NextResponse.json(
      {
        ok: false,
        error: message,
        hint:
          "Verifica .env.local, che lo schema sia applicato su Supabase Cloud e che la tabella venues esista.",
      },
      { status: 500 }
    )
  }
}
