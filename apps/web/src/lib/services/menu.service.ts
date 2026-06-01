import { createClient } from "@/lib/supabase/server"

export interface ProductVariant {
  id: string
  size_label: string | null
  price: number
  sort_order: number
  is_active: boolean
}

export interface ProductTag {
  id: string
  color: string | null
  name: string
}

export interface MenuProduct {
  id: string
  slug: string
  image_url: string | null
  sort_order: number
  is_active: boolean
  name: string
  description: string | null
  variants: ProductVariant[]
  tags: ProductTag[]
}

export interface MenuCategory {
  id: string
  slug: string
  icon: string | null
  sort_order: number
  name: string
  products: MenuProduct[]
}

export async function getMenuByVenue(
  venueId: string,
  locale = "it"
): Promise<MenuCategory[]> {
  const supabase = await createClient()

  const { data, error } = await supabase
    .from("categories")
    .select(
      `
      id, slug, icon, sort_order,
      category_labels!inner ( name, locale ),
      products (
        id, slug, image_url, sort_order, is_active,
        product_labels!inner ( name, description, locale ),
        product_variants ( id, size_label, price, sort_order, is_active ),
        product_tags (
          tags ( id, color, tag_labels ( name, locale ) )
        )
      )
    `
    )
    .eq("venue_id", venueId)
    .eq("is_active", true)
    .eq("category_labels.locale", locale)
    .order("sort_order")

  if (error) throw new Error(error.message)

  return (data ?? []).map((cat) => {
    const categoryLabel = Array.isArray(cat.category_labels)
      ? cat.category_labels[0]
      : cat.category_labels

    const products: MenuProduct[] = (
      (cat.products ?? []) as unknown as RawProduct[]
    )
      .filter((p) => p.is_active)
      .sort((a, b) => a.sort_order - b.sort_order)
      .map((p) => {
        const productLabel = Array.isArray(p.product_labels)
          ? p.product_labels[0]
          : p.product_labels

        const variants: ProductVariant[] = (
          (p.product_variants ?? []) as ProductVariant[]
        )
          .filter((v) => v.is_active)
          .sort((a, b) => a.sort_order - b.sort_order)

        const tags: ProductTag[] = (p.product_tags ?? [])
          .map((pt: RawProductTag) => {
            const tag = pt.tags
            if (!tag) return null
            const tagLabel = Array.isArray(tag.tag_labels)
              ? tag.tag_labels.find((tl: RawTagLabel) => tl.locale === locale) ??
                tag.tag_labels[0]
              : tag.tag_labels
            return {
              id: tag.id,
              color: tag.color ?? null,
              name: tagLabel?.name ?? "",
            }
          })
          .filter((t): t is ProductTag => t !== null)

        return {
          id: p.id,
          slug: p.slug,
          image_url: p.image_url ?? null,
          sort_order: p.sort_order,
          is_active: p.is_active,
          name: productLabel?.name ?? "",
          description: productLabel?.description ?? null,
          variants,
          tags,
        }
      })

    return {
      id: cat.id,
      slug: cat.slug,
      icon: cat.icon ?? null,
      sort_order: cat.sort_order,
      name: categoryLabel?.name ?? "",
      products,
    }
  })
}

interface RawTagLabel {
  name: string
  locale: string
}

interface RawTag {
  id: string
  color: string | null
  tag_labels: RawTagLabel[] | RawTagLabel | null
}

interface RawProductTag {
  tags: RawTag | null
}

interface RawProductLabel {
  name: string
  description: string | null
  locale: string
}

interface RawProduct {
  id: string
  slug: string
  image_url: string | null
  sort_order: number
  is_active: boolean
  product_labels: RawProductLabel[] | RawProductLabel | null
  product_variants: ProductVariant[] | null
  product_tags: RawProductTag[] | null
}
