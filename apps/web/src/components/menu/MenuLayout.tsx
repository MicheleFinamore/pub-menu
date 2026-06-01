"use client"

import { useState } from "react"
import type { MenuCategory } from "@/lib/services/menu.service"
import MenuHeader from "./MenuHeader"
import MenuNav from "./MenuNav"
import MenuHero from "./MenuHero"
import MenuCategorySection from "./MenuCategorySection"

interface Venue {
  id: string
  slug: string
  name: string
}

interface Props {
  venue: Venue
  settings: Record<string, string>
  categories: MenuCategory[]
}

export default function MenuLayout({ venue, settings, categories }: Props) {
  const [activeCategoryId, setActiveCategoryId] = useState(
    categories[0]?.id ?? ""
  )

  const activeCategory =
    categories.find((c) => c.id === activeCategoryId) ?? categories[0]
  const activeCategoryIndex = categories.findIndex(
    (c) => c.id === activeCategoryId
  )

  const tagline =
    settings["menu.hero_tagline"] ?? "Tutto quello che vuoi, servito bene."

  return (
    <div className="min-h-screen bg-[#120d05] text-[#f0e6d3]">
      <div className="sticky top-0 z-50">
        <MenuHeader venue={venue} />
        <MenuNav
          categories={categories}
          activeCategoryId={activeCategoryId}
          onSelect={setActiveCategoryId}
        />
      </div>

      <MenuHero venue={venue} tagline={tagline} />

      {activeCategory && (
        <MenuCategorySection
          category={activeCategory}
          index={activeCategoryIndex}
          total={categories.length}
        />
      )}

      {categories.length === 0 && (
        <div className="max-w-5xl mx-auto px-6 py-20 text-center">
          <p className="text-[#8a7a68] text-lg">
            Nessuna categoria disponibile al momento.
          </p>
        </div>
      )}

      <footer className="max-w-5xl mx-auto px-6 py-8 mt-12 border-t border-[#3a2d1f]">
        <p className="text-[#8a7a68] text-xs text-center tracking-widest">
          {settings["menu.footer_text"] ?? venue.name.toUpperCase()}
        </p>
      </footer>
    </div>
  )
}
