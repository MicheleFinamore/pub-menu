import { NextResponse } from "next/server"

export async function POST() {
  return NextResponse.json({ revalidated: false, message: "Da implementare in fase 11" })
}
