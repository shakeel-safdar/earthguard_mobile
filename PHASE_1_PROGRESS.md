# EarthGuard AI — Phase 1 Progress Report

**Date:** 14 Nov 2026 · **Scope:** UI/UX foundation only — local mock data, no backend
**Platforms:** Flutter mobile app (`mobile_app/`) · React admin dashboard (`admin_dashboard/`)

---

## ✅ Overall status

| Workstream | Status |
|---|---|
| Admin dashboard — 13 pages, dark/light themes, nav, charts, CSV export | ✅ Complete |
| Admin dashboard — production build (`npm run build`) | ✅ Passing (tsc strict + vite) |
| Mobile app — 14 screens + design system + custom charts/map | ✅ Complete |
| Mobile app — static analysis (`flutter analyze`) | ✅ Clean (0 issues) |
| Mobile app — widget test (`flutter test`) | ✅ Passing |
| Docs — README, UI/UX guidelines, progress report, .gitignore | ✅ Complete |
| Phase 2 prep — Supabase schema, RLS, web/mobile auth clients | ✅ Scaffolded (mock-safe, add keys to activate) |
| Backend / APIs / Supabase / auth | 🚫 Out of scope (Phase 2) |

---

## 🖥️ Admin dashboard (React 18 + TypeScript + Vite 6)

**Stack:** React 18.3 · TypeScript (strict, `noUnusedLocals`/`noUnusedParameters`) ·
Vite 6.4 · react-router-dom 6 · lucide-react · recharts

**Screens (13):**
1. ✅ Admin Login — split branding panel, mock sign-in (any credentials)
2. ✅ Overview — stat cards, incident mix chart, activity feed, regional map
3. ✅ Live Monitoring — system feeds, response-time chart, event stream
4. ✅ Disasters — filterable incident table with severity badges
5. ✅ Emergency Requests — SOS queue, status tabs + severity filter, team assignment cards
6. ✅ Rescue Teams — readiness grid, availability, equipment
7. ✅ Risk Analysis — radar + monthly trends, AI forecast card
8. ✅ Alerts — alert log with delivery volume chart
9. ✅ Shelters — occupancy cards, capacity bars, facility icons
10. ✅ Users — registered users table with region/role
11. ✅ Reports — composed charts + **client-side CSV export** (4 datasets)
12. ✅ Geographic View — interactive SVG Pakistan map, disaster+shelter markers, detail panel
13. ✅ Settings — theme picker (dark/light/system), profile form, notification toggles

**Design system:** CSS variables (`data-theme` attr) + `ThemeProvider`/`useTheme` with chart
tokens; sidebar (collapsible drawer < 1024 px) + topbar layout; Lucide icons;
severity/status badge components shared by all pages.

**Build:** `npm run build` → `tsc -b` + `vite build` passes.
Output: `dist/` (index.html + 8.2 KB CSS + 772.9 KB JS / 208.3 KB gzip).
TS fixes made during build hardening: discriminated-union nav config, severity filter
wiring, union-type guard in MapPage, unused-import cleanup.

---

## 📱 Mobile app (Flutter, zero external packages)

**Screens (14) — all complete:**

| # | Screen | File | Highlights |
|---|---|---|---|
| 1 | ✅ Splash | `onboarding/splash_screen.dart` | Fade-in branding, loading pulse, auto-advance |
| 2 | ✅ Onboarding | `onboarding/onboarding_screen.dart` | 3 slides, page indicator, skip |
| 3 | ✅ Login | `authentication/login_screen.dart` | Validation, remember me, forgot sheet |
| 4 | ✅ Register | `authentication/register_screen.dart` | Full form, city dropdown, terms |
| 5 | ✅ Home | `dashboard/home_screen.dart` | Risk gauge, quick actions, incidents, trend chart, contacts |
| 6 | ✅ Disaster Map | `disaster_map/disaster_map_screen.dart` | CustomPainter Pakistan map, filters, marker details |
| 7 | ✅ Risk Analysis | `risk_analysis/risk_analysis_screen.dart` | Gauge, hazard bars, trend, factors, AI advisory |
| 8 | ✅ SOS | `emergency_sos/sos_screen.dart` | Hold-to-confirm (1.6 s), type chips, sent flow, hotlines |
| 9 | ✅ Rescue Status | `rescue/rescue_screen.dart` | ETA strip, 5-step timeline, team card, notes |
| 10 | ✅ Alerts | `alerts/alerts_screen.dart` | Unread tracking, filters, detail sheet |
| 11 | ✅ Safe Zones / Shelters | `shelters/shelters_screen.dart` | Occupancy bars, facility chips, navigate/call |
| 12 | ✅ AI Assistant | `ai_assistant/ai_assistant_screen.dart` | Keyword-based replies, quick asks, typing bubble |
| 13 | ✅ Profile | `profile/profile_screen.dart` | Identity card, safety profile, menu |
| 14 | ✅ Settings | `profile/settings_screen.dart` | **Live theme toggle** (ThemeModeController), toggles, about |

**Shell:** `main_shell.dart` — bottom nav (Home · Map · **[red SOS FAB]** · Alerts · Profile)
with center notch, unread badges, IndexedStack state retention.

**Custom widgets (pure SDK, no packages):** `EgCard` · `EgBadge` (pulse dot) · `EgButton` ·
`EgSectionHeader` · `EgAvatar` · `EgProgressBar` · `EgGauge` (260° gradient arc) ·
`EgBarChart` · `EgLineChart` (tap-to-inspect) · `EgPakistanMap` (stylized geography,
pulse rings, selection) · `EgTextField`.

**Theming:** `AppTheme.light()/dark()` + `ThemeModeController` (ValueNotifier singleton) —
runtime switching from Settings; tokens per docs/UI_UX_GUIDELINES.md.

**Mock data (`core/mock/mock_data.dart`):** 6 disasters (Kotri floods, Chitral quakes,
Sibi heatwave, N-35 landslide, AS-04 cyclone, Tharparkar drought), 6 alerts, 6 shelters,
4 rescue teams, 3 SOS requests, 8 city markers, personal risk datasets — all Pakistan context.

**Quality gates:** `flutter analyze` → **No issues found!** · `flutter test` → 1/1 passing
(splash branding → onboarding navigation).

---

## 🐛 Issues found & fixed during verification

| Issue | Fix |
|---|---|
| Web: `item.icon` JSX type error in sidebar | navConfig refactored to discriminated union (`NavSection` \| `NavLinkEntry`) |
| Web: unused `setSeverity` in EmergencyPage | Wired a severity `<select>` filter into the SOS queue |
| Web: `selected.title` union error in MapPage | `'title' in selected` type guard |
| Web: unused `rescueTeams` import in OverviewPage | Removed |
| Mobile: `Padding(decoration: …)` invalid param in Home `_FactRow` | Replaced with `Container` + themed border |
| Mobile: `kCities` used but not imported in map painter | Added `mock_data.dart` import |
| Mobile: empty `TextButton` action in Home quick-actions header | Removed |
| Mobile: 8 unused imports across 6 screens | Cleaned |
| Mobile: missing closing paren in Onboarding `Padding`/`Column` | Added `),` |
| Mobile: invalid `?.()` call + unused tap state in `EgPakistanMap` | `?.call(...)`, removed unused `_tapDown`/`_transform` |
| Mobile: unused locals / stale lints (`scheme`, `color`, unused params) | Cleaned across Home, Rescue, Risk Analysis |
| Mobile: deprecated `Matrix4..scale` in Splash | `Matrix4.diagonal3Values` |
| Mobile: `DropdownButtonFormField.value` deprecation in Register | `initialValue` |
| Mobile: dangling library doc comments (`mock_data`, `geo_map_data`) | Converted to `//` |

---

## 🚀 Run commands

### Admin dashboard
```bash
cd admin_dashboard
npm install
npm run dev        # http://localhost:5173
npm run build      # production → dist/
```
(Windows, no Node on PATH: `cmd /c "set PATH=D:\TERRAGUARD_PK\.tools\nodejs;%PATH%&& cd /d D:\TERRAGUARD_PK\admin_dashboard && npm run dev"`)

### Mobile app
```bash
cd mobile_app
flutter pub get
flutter run        # device/emulator, or -d chrome for web
flutter analyze
flutter test
```

**Enable Supabase (Phase 2):** follow `docs/SUPABASE_SETUP.md`. Quick start:

```bash
# Web: copy admin_dashboard/.env.example -> .env and fill the two values, then npm run dev
# Mobile:
flutter run --dart-define=SUPABASE_URL=https://YOUR-PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR-ANON-KEY
```

**Mock sign-in:** any email + password on both platforms (until the Supabase keys are added).

---

## 🚧 Next phase candidates (not in Phase 1)

- Supabase integration (auth, realtime SOS pipeline, alert push) — **scaffold ready**, see `docs/SUPABASE_SETUP.md`
- Live PDMA / PMD / seismic data feeds
- Turn-by-turn shelter routing & maps SDK
- Direct calling/SMS from SOS & hotlines
- Role-based admin auth, audit logs
