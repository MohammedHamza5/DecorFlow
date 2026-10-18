-- Fix: Ensure handle_new_user trigger reads 'role' from raw_user_meta_data correctly
-- This replaces any old version that might be ignoring the role field.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  _role text;
BEGIN
  -- Read role from metadata, default to 'seller' only if not provided
  _role := COALESCE(new.raw_user_meta_data->>'role', 'seller');

  -- Validate role to prevent unexpected values
  IF _role NOT IN ('owner', 'manager', 'seller') THEN
    _role := 'seller';
  END IF;

  INSERT INTO public.profiles (id, full_name, phone, role, shop_name)
  VALUES (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'phone',
    _role,
    new.raw_user_meta_data->>'shop_name'
  )
  ON CONFLICT (id) DO UPDATE SET
    role = EXCLUDED.role,
    full_name = EXCLUDED.full_name,
    phone = EXCLUDED.phone,
    shop_name = EXCLUDED.shop_name;

  RETURN new;
END;
$$;

-- Re-create trigger to make sure it's using the updated function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
