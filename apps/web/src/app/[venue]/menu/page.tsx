type Props = {
  params: Promise<{ venue: string }>
}

export default async function VenueMenuPage({ params }: Props) {
  const { venue } = await params

  return (
    <main className="mx-auto max-w-lg p-6">
      <h1 className="text-2xl font-semibold">Menu — {venue}</h1>
      <p className="mt-2 text-muted-foreground">
        Menu pubblico (da implementare in fase 07).
      </p>
    </main>
  )
}
