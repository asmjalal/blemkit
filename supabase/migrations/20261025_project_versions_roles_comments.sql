-- SynappKit: version history, admin roles and widget comments.
-- Safe to run more than once.
--
-- NOTE: The editor signs users in with Firebase Auth and talks to Supabase
-- with the anon key, so auth.uid() is NULL in these requests. Row-level
-- security below therefore cannot tie rows to a user yet; moving editor
-- sign-in to Supabase Auth (or minting Supabase JWTs from Firebase tokens)
-- is required before these tables can be locked down per user.

-- 1. Version history (F7-01)
CREATE TABLE IF NOT EXISTS public.project_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    label TEXT,
    snapshot JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
CREATE INDEX IF NOT EXISTS project_versions_project_idx ON public.project_versions (project_id, created_at DESC);

-- Keep the 50 most recent versions per project.
CREATE OR REPLACE FUNCTION public.trim_project_versions() RETURNS trigger AS $$
BEGIN
  DELETE FROM public.project_versions
  WHERE project_id = NEW.project_id
    AND id NOT IN (
      SELECT id FROM public.project_versions
      WHERE project_id = NEW.project_id
      ORDER BY created_at DESC
      LIMIT 50
    );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trim_project_versions_trigger ON public.project_versions;
CREATE TRIGGER trim_project_versions_trigger
AFTER INSERT ON public.project_versions
FOR EACH ROW EXECUTE FUNCTION public.trim_project_versions();

-- 2. Admin roles (P0-10): replaces the e-mail pattern checks.
CREATE TABLE IF NOT EXISTS public.user_roles (
    email TEXT PRIMARY KEY,
    role TEXT NOT NULL DEFAULT 'admin' CHECK (role IN ('admin', 'reviewer')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Roles are readable" ON public.user_roles;
CREATE POLICY "Roles are readable" ON public.user_roles FOR SELECT USING (true);
-- Seed the existing admins. Edit roles from the Supabase dashboard (service role).
INSERT INTO public.user_roles (email, role) VALUES ('admin@gmail.com', 'admin') ON CONFLICT (email) DO NOTHING;

-- 3. Widget comments (F7-03)
CREATE TABLE IF NOT EXISTS public.project_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    screen_id TEXT,
    widget_id TEXT,
    author_email TEXT,
    author_name TEXT,
    body TEXT NOT NULL,
    resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);
CREATE INDEX IF NOT EXISTS project_comments_project_idx ON public.project_comments (project_id, created_at DESC);
