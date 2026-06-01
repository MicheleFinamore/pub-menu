import { NextResponse } from "next/server"
import {
  getVenueBySlug,
  getVenueSettings,
  getMenuByVenue,
} from "@/lib/services"

export const revalidate = 60

type Params = { params: Promise<{ venue: string }> }

export async function GET(_request: Request, { params }: Params) {
  const { venue } = await params

  const venueData = await getVenueBySlug(venue)
  if (!venueData) {
    return NextResponse.json({ error: "Venue not found" }, { status: 404 })
  }

  const [settings, categories] = await Promise.all([
    getVenueSettings(venueData.id),
    getMenuByVenue(venueData.id),
  ])

  return NextResponse.json(
    { venue: venueData, settings, categories },
    {
      headers: {
        "Cache-Control": "s-maxage=60, stale-while-revalidate=300",
      },
    }
  )
}
