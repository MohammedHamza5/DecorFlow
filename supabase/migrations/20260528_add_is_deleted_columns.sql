-- Migration: Add `is_deleted` column to support soft deletes for sync engine

ALTER TABLE public.projects ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.measurement_sessions ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.rooms ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.walls ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.wall_openings ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

ALTER TABLE public.products ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.product_variants ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.supplier_product_pricings ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

ALTER TABLE public.inventory_items ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.inventory_movements ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

ALTER TABLE public.quotes ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.quote_items ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

ALTER TABLE public.invoices ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.invoice_items ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE public.payments ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

-- Optional: Create indexes to speed up the sync engine queries
CREATE INDEX IF NOT EXISTS idx_projects_updated_at ON public.projects(updated_at);
CREATE INDEX IF NOT EXISTS idx_measurement_sessions_updated_at ON public.measurement_sessions(updated_at);
CREATE INDEX IF NOT EXISTS idx_rooms_updated_at ON public.rooms(updated_at);
CREATE INDEX IF NOT EXISTS idx_walls_updated_at ON public.walls(updated_at);
CREATE INDEX IF NOT EXISTS idx_products_updated_at ON public.products(updated_at);
CREATE INDEX IF NOT EXISTS idx_customers_updated_at ON public.customers(updated_at);
CREATE INDEX IF NOT EXISTS idx_quotes_updated_at ON public.quotes(updated_at);
CREATE INDEX IF NOT EXISTS idx_invoices_updated_at ON public.invoices(updated_at);
