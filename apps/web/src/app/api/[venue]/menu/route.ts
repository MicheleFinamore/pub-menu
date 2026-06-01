import { NextResponse } from "next/server"

export const revalidate = 60

type Params = { params: Promise<{ venue: string }> }

export async function GET(_request: Request, { params }: Params) {
  const { venue } = await params

  return NextResponse.json(
    { venue, message: "Menu API — da implementare in fase 06" },
    {
      headers: {
        "Cache-Control": "s-maxage=60, stale-while-revalidate=300",
      },
    }
  )
}
