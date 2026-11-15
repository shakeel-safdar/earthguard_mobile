# 🌍 EarthGuard AI

### Intelligent Disaster Management Platform for Pakistan

**Predict · Protect · Respond**

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![React](https://img.shields.io/badge/React-18.3-61DAFB?logo=react&logoColor=black)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-strict-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![Vite](https://img.shields.io/badge/Vite-6.4-646CFF?logo=vite&logoColor=white)](https://vitejs.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Postgres%20%2B%20Auth-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](#license)

EarthGuard AI is a two-platform emergency-response product built for Pakistan:

- 📱 **Citizen mobile app** — real-time risk awareness, disaster mapping, SOS dispatch,
  shelters, and an AI safety assistant.
- 🖥️ **Emergency Command Center** — a web dashboard for NDMA/PDMA operators to monitor
  incidents, triage SOS requests, coordinate rescue teams, and broadcast alerts.

The project pairs a complete, production-quality **design system** with a
**Supabase-ready backend** (Postgres schema, row-level security, auth, realtime SOS).

---

## 📑 Table of Contents

- [The Problem](#-the-problem)
- [The Solution](#-the-solution)
- [Key Features](#-key-features)
- [Screens](#-screens)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Design System](#-design-system)
- [Data Model](#-data-model)
- [Getting Started](#-getting-started)
- [Quality Gates](#-quality-gates)
- [Project Structure](#-project-structure)
- [Security](#-security)
- [Roadmap](#-roadmap)
- [Documentation](#-documentation)
- [License](#-license)

---

## 🚨 The Problem

Pakistan is one of the most climate-vulnerable countries in the world. Every year,
floods, earthquakes, heatwaves, cyclones, and landslides affect millions of people.
In a live emergency, three things fail at once:

1. **Citizens** don't know how much danger they are in, where to go, or how to call for help fast.
2. **Rescue teams** lack a shared, real-time picture of SOS requests and resource availability.
3. **Command centers** operate on fragmented phone calls, spreadsheets, and delayed reporting.

Existing tools are either government-only, English-only, or disconnected from the citizen.

## 💡 The Solution

EarthGuard AI closes that loop with one coordinated system:

| Layer | What it does |
|---|---|
| **Awareness** | Location-aware risk score, hazard breakdown, live disaster map, early-warning alerts |
| **Action** | One-tap hold-to-confirm SOS, nearest rescue-team dispatch, safe-zone routing |
| **Coordination** | Admin command center with SOS queue, rescue-team readiness, shelter capacity, reports |
| **Intelligence** | AI safety assistant, risk forecasting cards, incident-trend analytics |

Designed for the realities of Pakistan: low-bandwidth mobile, bilingual-friendly UI,
NDMA/Rescue 1122 terminology, and offline-first mock data that works even without a backend.

---

## ✨ Key Features

### 📱 Citizen Mobile App
- **Live risk score** with gauge, hazard breakdown, and 7-day trend
- **Disaster map** with severity markers and city-level detail
- **SOS** — hold-to-confirm (1.6 s) emergency request with type selection and dispatch timeline
- **Rescue status** — ETA, 5-step mission timeline, assigned team profile
- **Alerts** — unread tracking, severity filters, detail sheets
- **Safe zones / shelters** — occupancy, facilities, navigate & call actions
- **AI assistant** — keyword-driven safety guidance for floods, quakes, heatwaves
- **Profile & settings** — safety profile, hotlines, live dark/light theme switching

### 🖥️ Admin Command Center
- **Overview** — KPI cards, incident mix, activity feed, regional risk map
- **Live monitoring** — system feeds, response-time analytics, event stream
- **Disasters** — filterable incident table with severity badges
- **Emergency requests** — SOS queue, status tabs, severity filter, team assignment
- **Rescue teams** — readiness grid, availability, equipment
- **Risk analysis** — radar + trends, AI forecast card
- **Alerts** — broadcast log with delivery-volume chart
- **Shelters** — capacity bars, occupancy, facility icons
- **Users** — registered citizens with region/role
- **Reports** — composed charts + client-side CSV export (4 datasets)
- **Geographic view** — interactive SVG Pakistan map with markers and detail panel
- **Settings** — theme picker, profile form, notification toggles

---

## 🖼️ Screens

### Mobile — 14 screens
`Splash` · `Onboarding (3 slides)` · `Login` · `Register` · `Home` · `Disaster Map` ·
`Risk Analysis` · `SOS` · `Rescue Status` · `Alerts` · `Safe Zones/Shelters` ·
`AI Assistant` · `Profile` · `Settings`

Bottom navigation: **Home · Map · [ SOS ] · Alerts · Profile** — the red SOS action
sits in a prominent centre notch.

### Web — 13 screens
`Admin Login` · `Overview` · `Live Monitoring` · `Disasters` · `Emergency Requests` ·
`Rescue Teams` · `Risk Analysis` · `Alerts` · `Shelters` · `Users` · `Reports` ·
`Geographic View` · `Settings`

---

## 🏗️ Architecture

```
┌──────────────────────────────┐        ┌──────────────────────────────┐
│      Citizen Mobile App      │        │   Emergency Command Center   │
│   Flutter (Android/iOS/Web)  │        │   React 18 + TypeScript      │
└──────────────┬───────────────┘        └──────────────┬───────────────┘
               │                                        │
               │  Supabase Auth (JWT)                   │  Supabase Auth (JWT)
               │  PostgREST queries                     │  PostgREST queries
               │  Realtime channel (SOS)                │  Realtime channel (SOS)
               ▼                                        ▼
┌────────────────────────────────────────────────────────────────────────┐
│                              Supabase                                  │
│  ┌────────────┐  ┌─────────────────────────────────────────────────┐  │
│  │  Auth       │  │  Postgres + Row Level Security                  │  │
│  │  (GoTrue)   │  │  profiles · disasters · alerts · rescue_teams   │  │
│  └────────────┘  │  shelters · sos_requests · risk_scores          │  │
│                  └─────────────────────────────────────────────────┘  │
│  Realtime publication → sos_requests (live dispatch board)            │
└────────────────────────────────────────────────────────────────────────┘
```

**Graceful fallback:** both clients detect missing Supabase credentials and run in
**mock mode**, so the demo works on any machine without a backend.

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.41 · Dart 3.11 · **zero UI packages** (custom widgets, charts & map) |
| Mobile backend client | `supabase_flutter` |
| Web | React 18.3 · TypeScript (strict) · Vite 6.4 · React Router 6 |
| Web UI | Lucide icons · Recharts · hand-built SVG Pakistan map |
| Web backend client | `@supabase/supabase-js` |
| Backend | Supabase — Postgres, GoTrue Auth, PostgREST, Realtime |
| Styling | CSS variables + `data-theme` (web) · `ThemeExtension` tokens (mobile) |

---

## 🎨 Design System

A calm, high-contrast **Emergency Command Center** aesthetic — trustworthy navy,
teal accents for "safe", red reserved strictly for emergencies.

| Token | Dark | Light |
|---|---|---|
| Background | `#0B1220` | `#F4F7FB` |
| Surface | `#111D2E` | `#FFFFFF` |
| Text primary | `#F8FAFC` | `#142033` |
| Text secondary | `#9AA9BC` | `#66758A` |
| Accent (teal) | `#37D6A0` | `#159B78` |
| Danger | `#F04452` | `#DC3545` |

**Brand palette:** Navy `#10243B` · Blue `#193B5B` · Teal `#37D6A0` ·
Emergency `#F04452` · Warning `#F5A623` · Success `#22A06B`

- Cards **12–16 px** radius · buttons/fields **10–12 px**
- Spacing scale: **8 / 12 / 16 / 24 / 32**
- Icons: **Lucide** (web) · **Material Symbols** (mobile)
- Both themes are **hand-tuned** (not inverted); subtle pulses only for live/critical states
- Full specification: [`docs/UI_UX_GUIDELINES.md`](docs/UI_UX_GUIDELINES.md)

---

## 🗄️ Data Model

Defined in [`supabase/schema.sql`](supabase/schema.sql) with RLS on every table.

| Table | Purpose |
|---|---|
| `profiles` | 1:1 with `auth.users`; role = `citizen` / `rescuer` / `admin` |
| `disasters` | Incidents with severity, status, geo coordinates, impact |
| `alerts` | Early-warning broadcasts (push / SMS / in-app) |
| `rescue_teams` | Team readiness, location, equipment |
| `shelters` | Capacity, occupancy, facilities, status |
| `sos_requests` | Citizen emergencies + assignment + realtime status |
| `risk_scores` | Regional score + JSONB hazard breakdown |

**First registered account automatically becomes `admin`** (demo-friendly signup trigger).

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Flutter | 3.41.x (stable) |
| Node.js | 18+ |
| Supabase account | free tier is enough |

> Windows without Node on PATH: a portable runtime lives at `.tools/nodejs`.

### 1. Backend (Supabase)

1. Create a project at [supabase.com](https://supabase.com).
2. Run [`supabase/schema.sql`](supabase/schema.sql) in **SQL Editor**.
3. Enable **Authentication → Email** and turn **Confirm email OFF** for local dev.
4. Copy **Project URL** + **publishable/anon key**.

Full walkthrough: [`docs/SUPABASE_SETUP.md`](docs/SUPABASE_SETUP.md)

### 2. Admin Dashboard (Web)

```bash
cd admin_dashboard
cp .env.example .env          # add VITE_SUPABASE_URL + VITE_SUPABASE_ANON_KEY
npm install
npm run dev                   # → http://localhost:5173
npm run build                 # production build → dist/
```

> Without `.env`, the dashboard runs in mock mode and accepts any credentials.

### 3. Mobile App (Flutter)

```bash
cd mobile_app
flutter pub get
flutter run -d chrome         # or a connected device/emulator
# Optional explicit Supabase config:
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR-KEY
```

### 4. Sign in

- **First registration becomes admin** — no seed account required.
- If Supabase is not configured, any email/password works (mock mode).

---

## ✅ Quality Gates

| Gate | Command | Status |
|---|---|---|
| Web production build | `cd admin_dashboard && npm run build` | ✅ Passing (tsc strict + Vite) |
| Mobile static analysis | `cd mobile_app && flutter analyze` | ✅ **No issues found** |
| Mobile widget test | `cd mobile_app && flutter test` | ✅ 1/1 passing |
| Type safety | TypeScript `strict` + `noUnusedLocals` | ✅ Enforced |

---

## 📂 Project Structure

```
TERRAGUARD_PK/
├── mobile_app/                  # Flutter citizen app
│   ├── lib/
│   │   ├── core/
│   │   │   ├── theme/           # AppColors, AppTheme, ThemeModeController
│   │   │   ├── constants/       # spacing, radii, emergency numbers
│   │   │   ├── mock/            # models + Pakistan datasets
│   │   │   ├── routing/         # central route table
│   │   │   ├── supabase/        # config + auth service (mock-safe)
│   │   │   └── widgets/         # EgCard, EgBadge, charts, Pakistan map
│   │   ├── features/            # one folder per screen
│   │   └── main.dart
│   └── test/                    # widget tests
├── admin_dashboard/             # React + TypeScript command center
│   ├── src/
│   │   ├── components/          # Badge, StatCard, RiskMap, SparkChart…
│   │   ├── pages/               # 13 screens
│   │   ├── layouts/             # sidebar + topbar shell, navConfig
│   │   ├── hooks/               # useTheme + chart tokens
│   │   ├── lib/                 # supabase client + auth helpers
│   │   ├── data/                # mockData.ts
│   │   └── theme/               # tokens.ts
│   └── .env.example
├── supabase/
│   └── schema.sql               # tables, RLS, triggers, realtime, seed
├── docs/
│   ├── UI_UX_GUIDELINES.md
│   ├── PHASE_1_PROGRESS.md
│   └── SUPABASE_SETUP.md
└── .tools/                      # portable Node runtime (git-ignored)
```

---

## 🔐 Security

- **RLS enabled on every table** — no anonymous data access.
- Citizens can only insert/read/update **their own** SOS requests.
- Reference data is readable by authenticated users; **writes are admin-only**.
- `is_admin()` is a `SECURITY DEFINER` function to avoid RLS recursion.
- Only the **publishable/anon key** ever ships to clients — `service_role` is never used
  in the app.
- `.env` files are git-ignored; `.env.example` documents required variables.

---

## 🗺️ Roadmap

### ✅ Delivered
- Complete design system + 27 screens across two platforms
- Custom Flutter charts and a stylised Pakistan map (no external packages)
- Supabase schema, RLS policies, realtime publication, and seeded Pakistan data
- Auth wiring for web + mobile with graceful mock fallback
- Production build + static analysis + widget test green

### 🔜 Next
1. Replace mock datasets with Supabase queries on both clients
2. Live SOS pipeline: mobile insert → realtime admin dispatch board
3. Alert fan-out via Edge Functions + push notifications
4. Role-based route guards (citizen / rescuer / admin)
5. Shelter turn-by-turn routing and offline caching
6. Multilingual support (English / Urdu)

---

## 📚 Documentation

| Document | Description |
|---|---|
| [`docs/UI_UX_GUIDELINES.md`](docs/UI_UX_GUIDELINES.md) | Colour, type, spacing, component rules |
| [`docs/PHASE_1_PROGRESS.md`](docs/PHASE_1_PROGRESS.md) | Delivery report and screen checklist |
| [`docs/SUPABASE_SETUP.md`](docs/SUPABASE_SETUP.md) | Step-by-step backend setup |

---

## 📄 License

Released under the **MIT License**. See `LICENSE` for details.

---

<p align="center">
  <strong>EarthGuard AI</strong> — because in a disaster, the right information at the right time saves lives.
</p>
