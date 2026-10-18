-- Migration: Create Premium Features Tables
-- Created At: 2026-06-17

-- ─── 1. TECHNICIAN & WALLET TABLES ──────────────────────────────────────────

-- Create premium_technicians table
CREATE TABLE IF NOT EXISTS public.premium_technicians (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  phone text NOT NULL,
  title text NOT NULL, -- 'designer', 'electrician', 'carpenter', 'painter', 'contractor', etc.
  commission_rate numeric(5,2) DEFAULT 5.00, -- Default commission percentage (e.g. 5.00%)
  notes text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create premium_technician_transactions table
CREATE TABLE IF NOT EXISTS public.premium_technician_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  technician_id uuid NOT NULL REFERENCES public.premium_technicians(id) ON DELETE CASCADE,
  invoice_id uuid, -- Optional reference to invoice in core app
  amount numeric(15,2) NOT NULL, -- Positive for commission credit, negative for withdrawal
  transaction_type text NOT NULL, -- 'commission' (credit), 'withdrawal' (debit)
  status text NOT NULL DEFAULT 'completed', -- 'pending', 'completed', 'cancelled'
  notes text,
  created_at timestamp with time zone DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.premium_technicians ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.premium_technician_transactions ENABLE ROW LEVEL SECURITY;

-- Policies for premium_technicians
CREATE POLICY "Enable read access for authenticated users on premium_technicians" 
  ON public.premium_technicians FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users on premium_technicians" 
  ON public.premium_technicians FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for authenticated users on premium_technicians" 
  ON public.premium_technicians FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Enable delete for admin users on premium_technicians" 
  ON public.premium_technicians FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND profiles.role = 'owner'
    )
  );

-- Policies for premium_technician_transactions
CREATE POLICY "Enable read access for authenticated users on premium_technician_transactions" 
  ON public.premium_technician_transactions FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable insert for authenticated users on premium_technician_transactions" 
  ON public.premium_technician_transactions FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Enable update for admin/accountant on premium_technician_transactions" 
  ON public.premium_technician_transactions FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE profiles.id = auth.uid() AND (profiles.role = 'owner' OR profiles.role = 'manager')
    )
  );


-- ─── 2. INTERACTIVE WEB QUOTES TABLE ──────────────────────────────────────────

-- Create premium_web_quotes table
CREATE TABLE IF NOT EXISTS public.premium_web_quotes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quote_id uuid NOT NULL UNIQUE, -- references quotes(id) in core app
  share_token text NOT NULL UNIQUE, -- secret token for public access URL
  allow_customization boolean DEFAULT true,
  show_alternatives boolean DEFAULT true,
  customer_notes text,
  confirmed_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.premium_web_quotes ENABLE ROW LEVEL SECURITY;

-- Policies for premium_web_quotes
-- Web quotes must be readable by public clients using the token, so we allow select using true (public)
-- but restrict inserts/updates to authenticated users or token checks
CREATE POLICY "Enable public read access for premium_web_quotes" 
  ON public.premium_web_quotes FOR SELECT USING (true);

CREATE POLICY "Enable write access for authenticated users on premium_web_quotes" 
  ON public.premium_web_quotes FOR ALL USING (auth.role() = 'authenticated');


-- ─── 3. DESIGN ADVISOR TABLES ──────────────────────────────────────────────────

-- Create premium_design_templates table
CREATE TABLE IF NOT EXISTS public.premium_design_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE, -- NULL means public global system preset
  title_ar text NOT NULL,
  title_en text,
  description_ar text,
  image_url text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create premium_template_materials table
CREATE TABLE IF NOT EXISTS public.premium_template_materials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id uuid NOT NULL REFERENCES public.premium_design_templates(id) ON DELETE CASCADE,
  product_category text NOT NULL, -- e.g. 'wood_louver', 'marble_alternative', 'adhesive', etc.
  calculation_rule text NOT NULL, -- e.g. 'panel_center_one_third', 'louver_edges_two_thirds', 'fixed_count'
  unit_multiplier numeric(10,2) DEFAULT 1.00,
  is_optional boolean DEFAULT false
);

-- Enable RLS
ALTER TABLE public.premium_design_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.premium_template_materials ENABLE ROW LEVEL SECURITY;

-- Policies for premium_design_templates
CREATE POLICY "Enable read access for authenticated users on premium_design_templates" 
  ON public.premium_design_templates FOR SELECT USING (true); -- viewable by all (even client webs)

CREATE POLICY "Enable write access for authenticated users on premium_design_templates" 
  ON public.premium_design_templates FOR ALL USING (auth.role() = 'authenticated');

-- Policies for premium_template_materials
CREATE POLICY "Enable read access for premium_template_materials" 
  ON public.premium_template_materials FOR SELECT USING (true);

CREATE POLICY "Enable write access for premium_template_materials" 
  ON public.premium_template_materials FOR ALL USING (auth.role() = 'authenticated');


-- ─── 4. RESTOCK RADAR TABLES ──────────────────────────────────────────────────

-- Create premium_supplier_contacts table
CREATE TABLE IF NOT EXISTS public.premium_supplier_contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  contact_person text,
  phone text NOT NULL,
  email text,
  category_supplied text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create premium_inventory_radar table (extends core app's product variants with premium reorder settings)
CREATE TABLE IF NOT EXISTS public.premium_inventory_radar (
  product_variant_id uuid PRIMARY KEY, -- refers to product_variants(id) in core app
  supplier_id uuid REFERENCES public.premium_supplier_contacts(id) ON DELETE SET NULL,
  safety_stock_override numeric(10,2), -- manual safety stock threshold
  restock_order_quantity numeric(10,2) DEFAULT 50.00,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.premium_supplier_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.premium_inventory_radar ENABLE ROW LEVEL SECURITY;

-- Policies for premium_supplier_contacts
CREATE POLICY "Enable read access for authenticated users on premium_supplier_contacts" 
  ON public.premium_supplier_contacts FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable write access for authenticated users on premium_supplier_contacts" 
  ON public.premium_supplier_contacts FOR ALL USING (auth.role() = 'authenticated');

-- Policies for premium_inventory_radar
CREATE POLICY "Enable read access for authenticated users on premium_inventory_radar" 
  ON public.premium_inventory_radar FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Enable write access for authenticated users on premium_inventory_radar" 
  ON public.premium_inventory_radar FOR ALL USING (auth.role() = 'authenticated');
