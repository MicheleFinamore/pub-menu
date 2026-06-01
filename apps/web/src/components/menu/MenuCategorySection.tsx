import type { MenuCategory } from "@/lib/services/menu.service"
import ProductCard from "./ProductCard"

interface Props {
  category: MenuCategory
  index: number
  total: number
}

export default function MenuCategorySection({ category, index, total }: Props) {
  const indexStr = String(index + 1).padStart(2, "0")
  const totalStr = String(total).padStart(2, "0")

  const activeProducts = category.products.filter(
    (p) => p.is_active && p.name.trim() !== ""
  )

  return (
    <section className="max-w-5xl mx-auto px-6 py-12 border-t border-[#3a2d1f]">
      <div className="grid grid-cols-1 md:grid-cols-[280px_1fr] gap-10 md:gap-16">
        {/* Left: category info */}
        <div className="md:sticky md:top-[104px] self-start">
          <p className="text-[#8a7a68] text-xs tracking-[0.2em] mb-4">
            {indexStr} / {totalStr}
          </p>
          <h2 className="font-serif text-4xl md:text-5xl text-[#f0e6d3] leading-tight">
            {category.name}
          </h2>
          {category.icon && (
            <p className="mt-3 text-2xl">{category.icon}</p>
          )}
        </div>

        {/* Right: product list */}
        <div>
          {activeProducts.length === 0 ? (
            <p className="text-[#8a7a68] text-sm italic pt-2">
              Nessun prodotto disponibile.
            </p>
          ) : (
            <div>
              {activeProducts.map((product) => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          )}
        </div>
      </div>
    </section>
  )
}
