import { notFound } from "next/navigation"
import { getVenueBySlug, getMenuByVenue, getVenueSettings } from "@/lib/services"
import MenuLayout from "@/components/menu/MenuLayout"

export const revalidate = 60

type Props = {
  params: Promise<{ venue: string }>
}

export default async function VenueMenuPage({ params }: Props) {
  const { venue: venueSlug } = await params

  const venue = await getVenueBySlug(venueSlug)
  if (!venue) {
    notFound()
  }

  const [settings, categories] = await Promise.all([
    getVenueSettings(venue.id),
    getMenuByVenue(venue.id),
  ])

  return (
    <MenuLayout venue={venue} settings={settings} categories={categories} />
  )
}
