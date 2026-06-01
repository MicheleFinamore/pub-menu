import Link from "next/link"

interface Venue {
  id: string
  slug: string
  name: string
}

interface Props {
  venue: Venue
}

export default function MenuHeader({ venue }: Props) {
  const year = new Date().getFullYear()
  const initial = venue.name.charAt(0).toUpperCase()

  return (
    <header className="bg-[#0e0904] border-b border-[#3a2d1f] px-4 py-3">
      <div className="max-w-5xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-[#c8873a] flex items-center justify-center text-[#0e0904] font-bold text-sm shrink-0">
            {initial}
          </div>
          <div className="flex items-baseline gap-2">
            <span className="text-[#f0e6d3] font-medium text-sm tracking-wide">
              {venue.name.toUpperCase()}
            </span>
            <span className="text-[#8a7a68] text-xs tracking-widest">
              MENÙ · {year}
            </span>
          </div>
        </div>
        <Link
          href="/admin"
          className="text-[#8a7a68] text-xs tracking-widest hover:text-[#c8873a] transition-colors duration-200"
        >
          ADMIN
        </Link>
      </div>
    </header>
  )
}
