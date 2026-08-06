-- SQL schema migration for Synappkit template marketplace and categories
-- Safe script that can be run on new or existing database.

-- 1. Create categories table
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    icon TEXT,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Enable RLS on categories
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to categories" 
    ON public.categories FOR SELECT 
    USING (true);

CREATE POLICY "Allow admin write access to categories" 
    ON public.categories FOR ALL 
    USING (auth.jwt() ->> 'email' LIKE '%@synappkit.com' OR auth.jwt() ->> 'email' = 'admin@gmail.com');

-- 3. Modify templates table to support categories, statuses, and creator tracking
CREATE TABLE IF NOT EXISTS public.templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    category TEXT, -- Legacy text category
    screens_json JSONB,
    queries_json JSONB DEFAULT '{}'::jsonb,
    thumbnail_url TEXT,
    is_premium BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Add new columns safely if they do not exist
ALTER TABLE public.templates ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL;
ALTER TABLE public.templates ADD COLUMN IF NOT EXISTS creator_id UUID; -- Firebase UID or Supabase Auth UID
ALTER TABLE public.templates ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'pending_approval', 'published'));

-- 4. Enable RLS on templates
ALTER TABLE public.templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to published templates" 
    ON public.templates FOR SELECT 
    USING (status = 'published');

CREATE POLICY "Allow creators to read their own drafts/pending templates" 
    ON public.templates FOR SELECT 
    USING (creator_id::text = auth.uid()::text);

CREATE POLICY "Allow authenticated creators to insert templates" 
    ON public.templates FOR INSERT 
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow creators to update their own draft templates" 
    ON public.templates FOR UPDATE 
    USING (creator_id::text = auth.uid()::text AND status = 'draft')
    WITH CHECK (creator_id::text = auth.uid()::text AND status IN ('draft', 'pending_approval'));

CREATE POLICY "Allow admins full access to templates" 
    ON public.templates FOR ALL 
    USING (auth.jwt() ->> 'email' LIKE '%@synappkit.com' OR auth.jwt() ->> 'email' = 'admin@gmail.com');

-- 5. Create downloads tracking table
CREATE TABLE IF NOT EXISTS public.downloads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID, -- References Firebase or Supabase User UID
    template_id UUID REFERENCES public.templates(id) ON DELETE CASCADE,
    downloaded_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 6. Enable RLS on downloads
ALTER TABLE public.downloads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow users to read their own downloads" 
    ON public.downloads FOR SELECT 
    USING (user_id::text = auth.uid()::text);

CREATE POLICY "Allow authenticated users to insert downloads" 
    ON public.downloads FOR INSERT 
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Allow admins full access to downloads" 
    ON public.downloads FOR ALL 
    USING (auth.jwt() ->> 'email' LIKE '%@synappkit.com' OR auth.jwt() ->> 'email' = 'admin@gmail.com');

-- 7. Seed initial default categories
INSERT INTO public.categories (name, icon, order_index) VALUES
('E-Commerce & Retail', 'shopping_bag_outlined', 1),
('Food & Grocery Delivery', 'restaurant_menu_outlined', 2),
('Banking & Finance', 'account_balance_wallet_outlined', 3),
('Social Media & Chat', 'chat_bubble_outline', 4),
('Healthcare & Fitness', 'fitbit_outlined', 5),
('Education & Learning', 'school_outlined', 6),
('Travel & Transport', 'flight_takeoff_outlined', 7),
('Productivity & Tasks', 'checklist_outlined', 8),
('Real Estate & Property', 'home_work_outlined', 9),
('Entertainment & Music', 'music_note_outlined', 10),
('News & Blogs', 'newspaper_outlined', 11),
('Events & Booking', 'event_available_outlined', 12),
('Smart Home & IoT', 'smart_toy_outlined', 13),
('Utilities & Tools', 'construction_outlined', 14),
('Business & CRM', 'business_center_outlined', 15)
ON CONFLICT (name) DO UPDATE SET 
    icon = EXCLUDED.icon,
    order_index = EXCLUDED.order_index;
