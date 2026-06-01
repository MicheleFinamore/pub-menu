import type { MenuProduct } from "@/lib/services/menu.service"

interface Props {
  product: MenuProduct
}

function formatPrice(price: number): string {
  return `€${price.toFixed(2).replace(".", ",")}`
}

export default function ProductCard({ product }: Props) {
  const activeVariants = product.variants
    .filter((v) => v.is_active)
    .sort((a, b) => a.sort_order - b.sort_order)

  const priceString = activeVariants
    .map((v) => {
      const sizeLabel = v.size_label?.trim()
      return sizeLabel
        ? `${sizeLabel} ${formatPrice(v.price)}`
        : formatPrice(v.price)
    })
    .join(" · ")

  return (
    <div className="py-4 border-b border-[#3a2d1f] last:border-b-0">
      <div className="flex items-start justify-between gap-4">
        {/* Name + description + tags */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center gap-2 flex-wrap">
            <span className="text-[#f0e6d3] font-medium leading-snug">
              {product.name}
            </span>
            {product.tags.map((tag) => (
              <span
                key={tag.id}
                className="inline-block text-[10px] px-1.5 py-0.5 rounded font-semibold tracking-wide uppercase leading-none"
                style={{
                  backgroundColor: tag.color ? `${tag.color}2a` : "#c8873a2a",
                  color: tag.color ?? "#c8873a",
                  border: `1px solid ${tag.color ? `${tag.color}55` : "#c8873a55"}`,
                }}
              >
                {tag.name}
              </span>
            ))}
          </div>
          {product.description && (
            <p className="text-[#8a7a68] text-sm mt-1 leading-relaxed">
              {product.description}
            </p>
          )}
        </div>

        {/* Price */}
        {priceString && (
          <div className="text-[#c8873a] text-sm font-medium whitespace-nowrap shrink-0 pt-0.5">
            {priceString}
          </div>
        )}
      </div>
    </div>
  )
}
