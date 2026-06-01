# Pub Menu Requirements and Architecture

Last Updated: 2026-06-01

## Product Context

Pub Menu is a multi-tenant web platform for pubs/bars/restaurants to publish a digital menu and manage it from an admin area.

Core goal:

- customers browse a fast public menu without login
- venue admins manage menu content, ordering, pricing, tags, images, and text settings

## Product Surfaces

### Public Menu

- Route pattern: `/{venue}/menu`
- No authentication required
- Must render active categories/products/variants clearly on mobile-first layouts

### Admin Web App

- Route area: `/admin/*` inside `apps/web`
- Protected by auth/middleware
- Used to manage:
  - categories
  - products
  - product variants/prices
  - tags/badges
  - textual settings
  - product image uploads
  - ordering/sorting flows

Note: admin is a mandatory product surface, not optional.

## Non-Negotiable Delivery Requirement

- The Admin Web App must be implemented as part of the product scope.
- A project state where only the public menu exists is considered incomplete.
- Structural decisions should preserve and support the admin roadmap.

## Architecture Goals

- Single codebase, multi-tenant isolation by design
- Stable domain boundaries (UI vs services vs DB integration)
- Fast public rendering with predictable data contract
- Admin writes reflected in public menu without manual redeploy

## Technical Stack

- Monorepo: `pnpm workspaces` + `turbo`
- Web application: Next.js App Router + TypeScript + Tailwind + shadcn
- Data/Auth/Storage: Supabase (Postgres + RLS + Auth + Storage)
- Shared DB integration: `packages/db` (`@pub/db`)

## High-Level Repository Structure

- `apps/web`
  - `src/app`: public/admin routes and route handlers
  - `src/components`: UI components
  - `src/lib/services`: domain services
  - `src/lib/supabase`: client setup
  - `src/middleware.ts`: auth/route guards
- `packages/db/src`: typed DB integration (`admin.ts`, `client.ts`, `env.ts`, `queries.ts`, `types.ts`)
- `supabase/migrations`: DB schema history
- `supabase/seed.sql`: seed data

## Domain and Data Model

Core entities:

- `venues`
- `venue_users`
- `app_settings`
- `categories` + `category_labels`
- `products` + `product_labels`
- `product_variants`
- `tags` + `tag_labels`
- `product_tags`

Label tables (`*_labels`) keep textual content flexible and ready for localization.

## Multi-Tenant and Security Model

- Tenant boundaries are enforced in DB (RLS + tenant-aware relations)
- Auth uses Supabase Auth
- Admin writes are scoped to venue ownership/role rules
- Public reads expose only active records intended for customers

## Service and Module Boundaries

- UI components should not contain low-level DB/request logic
- Domain data flows should go through `apps/web/src/lib/services`
- Shared typed DB concerns belong in `packages/db`
- Existing services should be reused/extended before creating new ones
- Components must stay feature-focused and avoid becoming oversized generic containers

## Route and API Contract Principles

- Public menu should be driven by a stable payload contract
- Route handlers and services should keep business logic centralized
- Error/loading/empty states must be explicit for both public and admin flows

## Migrations Status

Current migration files:

- `20240101000000_init.sql`
- `20240102000000_demo_data.sql`

When a migration changes schema or boundaries, update this document and `docs/architecture/CHANGELOG.md` in the same task.
