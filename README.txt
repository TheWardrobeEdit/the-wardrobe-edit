THE WARDROBE EDIT — v0.8 WEBSITE FOUNDATION

WHAT IS INCLUDED
- Public luxury black-and-gold landing page
- Public registration page
- Login page
- Forgot-password and reset-password pages
- Authenticated dashboard shell
- Supabase client integration (configuration placeholders)
- Initial PostgreSQL schema with owner-only Row Level Security policies
- Private garment-image storage bucket and per-user folder policies
- Original v0.7 app preserved as legacy-v0.7.html

IMPORTANT STATUS
This is the first website foundation, not yet a live deployed website. Authentication becomes operational after a Supabase project is created, schema.sql is applied, the project URL and public anon/publishable key are added to assets/config.js, and the site's redirect URLs are configured in Supabase. The existing v0.7 localStorage wardrobe has not yet been migrated into the database. That is the next integration stage.

SETUP
1. Create a free Supabase project.
2. Open SQL Editor and run supabase/schema.sql.
3. In Supabase Authentication > URL Configuration, add the eventual Cloudflare Pages URL to Site URL and Redirect URLs. During local testing, add http://localhost:8000/**.
4. Copy the Project URL and public anon/publishable key into assets/config.js. Never use a service_role key in browser code.
5. Test registration, email verification, login, password reset and logout.
6. Deploy this folder to Cloudflare Pages as a static site.

LOCAL PREVIEW
Run a local static server from this folder, for example:
  python -m http.server 8000
Then open http://localhost:8000

SECURITY
The browser key is the public anon/publishable key only. Private data access is enforced by PostgreSQL Row Level Security. Do not disable RLS. Do not place service_role keys, database passwords or other secrets in this project.

NEXT DEVELOPMENT STAGE
Connect the existing v0.7 wardrobe and outfit engine to the authenticated user's database records, migrate the local wardrobe safely, and test with two independent accounts to verify isolation.
