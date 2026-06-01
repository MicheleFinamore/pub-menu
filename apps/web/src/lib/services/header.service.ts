import { getVenueSettings } from "./venue.service"

export interface HeaderData {
  title: string
  subtitle: string
  adminLabel: string
}

export async function getHeaderData(venueId: string): Promise<HeaderData> {
  const settings = await getVenueSettings(venueId)

  return {
    title: settings["site.title"] ?? "",
    subtitle: settings["menu.hero_tagline"] ?? "",
    adminLabel: settings["header.admin_label"] ?? "Admin",
  }
}
