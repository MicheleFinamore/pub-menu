interface Venue {
  id: string
  slug: string
  name: string
}

interface Props {
  venue: Venue
  tagline: string
}

export default function MenuHero({ venue, tagline }: Props) {
  return (
    <section className="px-6 pt-16 pb-12 max-w-5xl mx-auto">
      <p className="text-[#c8873a] text-xs tracking-[0.3em] uppercase mb-5">
        {venue.name}
      </p>
      <h1 className="font-serif text-5xl md:text-7xl text-[#f0e6d3] leading-[1.1] mb-6">
        Il menù,
        <br />
        servito bene.
      </h1>
      {tagline && (
        <p className="text-[#8a7a68] text-base md:text-lg max-w-md leading-relaxed">
          {tagline}
        </p>
      )}
      <div className="mt-10 w-12 h-px bg-[#c8873a]" />
    </section>
  )
}
