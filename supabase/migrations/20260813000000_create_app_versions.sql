-- Create app_versions table to manage OTA updates
CREATE TABLE IF NOT EXISTS public.app_versions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    version VARCHAR NOT NULL,
    platform VARCHAR NOT NULL, -- e.g., 'windows_offline', 'android', 'web'
    download_url TEXT NOT NULL,
    release_notes TEXT,
    is_required BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.app_versions ENABLE ROW LEVEL SECURITY;

-- Allow read access to everyone
CREATE POLICY "Allow read access to app_versions to everyone" ON public.app_versions
    FOR SELECT USING (true);

-- Allow write access only to authenticated users
CREATE POLICY "Allow insert/update/delete for authenticated users" ON public.app_versions
    FOR ALL USING (auth.role() = 'authenticated');
