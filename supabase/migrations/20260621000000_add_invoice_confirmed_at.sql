-- Migration: Add confirmed_at to invoices to support sync engine
ALTER TABLE public.invoices ADD COLUMN IF NOT EXISTS confirmed_at timestamp with time zone;
