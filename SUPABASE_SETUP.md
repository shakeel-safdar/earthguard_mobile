# EarthGuard AI — Supabase Setup (Phase 2, Step by Step)

This guide connects the existing Phase 1 UI (Flutter mobile + React admin) to a real
Supabase backend: Postgres database, row-level security, auth, and realtime SOS.

> **Important:** The UI already works **without** Supabase in mock mode. Once you add
> the two environment values below, the app automatically switches to real auth.
> Never put the `service_role` key in the mobile app or the browser. Only use the
> `anon public` key on the client.

---

## Step 1 — Create the Supabase project (browser, ~3 min)

1. Open <https://supabase.com> and sign in (GitHub or email).
2. Click **New project**.
3. Fill in:
   - **Name:** `earthguard`
   - **Database Password:** choose a strong password and save it somewhere safe.
   - **Region:** `Southeast Asia (Singapore)` or `Mumbai` (closest to Pakistan).
4. Click **Create new project** and wait ~2 minutes for provisioning.

## Step 2 — Copy your API keys

1. In the project, go to **Project Settings → API** (or **Data API** in newer dashboards).
2. Copy these two values:
   - **Project URL** — looks like `https://abcdefgh.supabase.co`
   - **anon public** key — a long `eyJ...` JWT (this one is safe for clients).
3. Keep the **service_role** key private — it is only for server/scripts, never in the app.

## Step 3 — Create the database schema

1. In the left sidebar open **SQL Editor → New query**.
2. Open `supabase/schema.sql` from this repo, copy **all** of it, paste into the editor.
3. Click **Run** (Ctrl/Cmd + Enter). It creates every table, RLS policy, trigger, and
   seeds Pakistan mock data.
4. Confirm under **Table Editor** that these tables exist:
   `profiles`, `disasters`, `alerts`, `rescue_teams`, `shelters`, `sos_requests`, `risk_scores`.

## Step 4 — Configure Auth

1. Go to **Authentication → Providers → Email** and make sure **Email** is enabled.
2. For local development, go to **Authentication → Sign In / Providers** and turn
   **Confirm email** *off* so `signUp` logs the user in immediately. Turn it back on
   for production.
3. (Optional) **Authentication → URL Configuration**:
   - Site URL: `http://localhost:5173`
   - Redirect URLs: `http://localhost:5173/**`

## Step 5 — Create an admin account

1. Open the app (web or mobile) and **Register** with your email/password.
   - The **first registered account automatically becomes `admin`** (the signup trigger
     promotes the first profile when no admin exists yet).
   - If email confirmation is on, confirm via the email link first.
2. To promote a different user later, run this in **SQL Editor**:

```sql
update public.profiles p
set role = 'admin'
from auth.users u
where u.id = p.id
  and u.email = 'admin@earthguard.pk';   -- <- your email
```

Admins can read/write all tables. Citizens can only insert their own SOS and read
reference data.

---

## Step 6 — Connect the React admin dashboard

1. Create `admin_dashboard/.env` (copy from `.env.example`):

```env
VITE_SUPABASE_URL=https://YOUR-PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR-ANON-PUBLIC-KEY
```

2. Install the SDK and run:

```bash
cd admin_dashboard
npm install
npm run dev          # http://localhost:5173
```

3. Sign in with the admin account you created. When the env vars are missing the
   login page stays in **mock mode** and accepts any credentials, so the UI never breaks.

Files added:

- `src/lib/supabase.ts` — creates the client and exposes `isSupabaseConfigured`.
- `src/lib/auth.ts` — `signIn`, `signUp`, `signOut` with mock fallback.
- `.env.example` — the two variables (copy to `.env`).

## Step 7 — Connect the Flutter mobile app

Supabase values are passed at build/run time with `--dart-define` (no secret in the repo):

```bash
cd mobile_app
flutter pub get

flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR-ANON-PUBLIC-KEY
```

Windows PowerShell example:

```powershell
flutter run -d chrome `
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR-ANON-PUBLIC-KEY
```

You can also create `mobile_app/.env.json` and run `flutter run --dart-define-from-file=.env.json`:

```json
{
  "SUPABASE_URL": "https://YOUR-PROJECT.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR-ANON-PUBLIC-KEY"
}
```

Files added:

- `lib/core/supabase/supabase_config.dart` — reads the compile-time defines.
- `lib/core/supabase/supabase_service.dart` — init + auth with mock fallback.
- `lib/main.dart` — calls `SupabaseService.init()` before `runApp`.

---

## Step 8 — Verify it works

Checklist:

- [ ] Web login with the admin email/password succeeds; wrong password shows an error.
- [ ] Mobile login with the same account succeeds.
- [ ] `select * from public.profiles;` shows one row per registered user.
- [ ] `select * from public.disasters;` returns the seeded Pakistan incidents.
- [ ] Deleting the `.env` / omitting `--dart-define` returns the app to mock mode (still builds).

---

## How the mock fallback works

Both clients check whether the URL + anon key exist:

- **Configured** → calls Supabase Auth (`signInWithPassword`, `signUp`, `signOut`).
- **Not configured** → simulates a short delay and accepts any credentials, exactly like
  Phase 1. This keeps the demo runnable on any machine/CI without a backend.

## Security rules baked into `supabase/schema.sql`

- RLS is **enabled on every table**.
- `profiles`: users read/update only their own row; admins read all.
- Reference tables (`disasters`, `alerts`, `rescue_teams`, `shelters`, `risk_scores`):
  authenticated users can read; only admins can write.
- `sos_requests`: users insert/read/update their own; admins can read/update all.
- `is_admin()` is a `security definer` function so policies do not recurse.
- Realtime is enabled for `sos_requests` (dispatch board).

## Next steps (Phase 2 backlog)

1. Replace `mockData.ts` / `mock_data.dart` reads with Supabase queries.
2. Wire SOS submit to `insert into sos_requests` and subscribe to realtime on the admin
   Emergency page.
3. Add alert fan-out (DB trigger → Edge Function → push).
4. Role-based route guards on both clients.
5. Storage buckets for incident photos and rescue-team documents.
