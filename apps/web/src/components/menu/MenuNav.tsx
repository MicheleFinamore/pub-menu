import type { MenuCategory } from "@/lib/services/menu.service"

interface Props {
  categories: MenuCategory[]
  activeCategoryId: string
  onSelect: (id: string) => void
}

export default function MenuNav({ categories, activeCategoryId, onSelect }: Props) {
  if (categories.length === 0) return null

  return (
    <nav className="bg-[#0e0904] border-b border-[#3a2d1f] overflow-x-auto scrollbar-none">
      <div className="max-w-5xl mx-auto flex px-4">
        {categories.map((category) => {
          const isActive = category.id === activeCategoryId
          return (
            <button
              key={category.id}
              onClick={() => onSelect(category.id)}
              className={[
                "px-4 py-3 text-xs font-medium tracking-widest whitespace-nowrap border-b-2 transition-colors duration-200",
                isActive
                  ? "border-[#c8873a] text-[#f0e6d3]"
                  : "border-transparent text-[#8a7a68] hover:text-[#f0e6d3]",
              ].join(" ")}
            >
              {category.name.toUpperCase()}
            </button>
          )
        })}
      </div>
    </nav>
  )
}
