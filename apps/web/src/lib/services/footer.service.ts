import { getVenueSettings } from "./venue.service"

export interface FooterData {
  text: string
}

export async function getFooterData(venueId: string): Promise<FooterData> {
  const settings = await getVenueSettings(venueId)

  return {
    text: settings["menu.footer_text"] ?? "",
  }
}
