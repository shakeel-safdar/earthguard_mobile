# EarthGuard AI — UI/UX Guidelines (Phase 1)

These guidelines govern both the Flutter mobile app and the React admin dashboard.
Goal: a calm, high-legibility **Emergency Command Center** aesthetic that stays readable
under stress — dark-first, but with a genuinely designed light mode (not inverted colors).

---

## 1. Color system

### Brand palette
| Name | Hex | Usage |
|---|---|---|
| Navy | `#10243B` | Brand blocks, logo tiles, primary text on light surfaces |
| Blue | `#193B5B` | Secondary surfaces, gradients (subtle only) |
| Teal | `#37D6A0` | Primary accent (dark mode), positive/active states |
| Emergency | `#F04452` | SOS, critical severity, destructive actions |
| Warning | `#F5A623` | High severity, cautions |
| Success | `#22A06B` | Low severity, resolved/safe states |

### Theme tokens
| Token | Dark | Light |
|---|---|---|
| `--bg` | `#0B1220` | `#F4F7FB` |
| `--bg-subtle` | `#0D1526` | `#EAF0F7` |
| `--surface` | `#111D2E` | `#FFFFFF` |
| `--surface-2` | `#16243A` | `#F8FAFD` |
| `--surface-hover` | `#1A2A44` | `#F1F5FA` |
| `--border` | `#22334D` | `#DDE5EE` |
| `--border-strong` | — | `#C6D2E0` |
| `--text-primary` | `#F8FAFC` | `#142033` |
| `--text-secondary` | `#9AA9BC` | `#66758A` |
| `--text-tertiary` | `#6C7E95` | `#93A1B5` |
| `--accent` | `#37D6A0` | `#159B78` |
| `--accent-soft` | teal @ 14% | `#159B78` @ 12% |
| `--danger` | `#F04452` | `#DC3545` |

### Severity ramp (functional color coding — identical in both themes)
`critical` → danger red · `high` → warning amber · `moderate` → theme accent ·
`low` → success green. Chart grids/borders use muted theme tokens, never pure gray.

### Map palette
| Token | Dark | Light |
|---|---|---|
| Water | `#122743` | `#DBE7F3` |
| Land | `#16273F` | `#F0EDE4` |
| Land stroke | `#24395A` | `#D8D2C2` |

---

## 2. Typography

- Web: system UI stack (`Inter`-like rendering via system fonts); monospace for IDs/codes.
- Mobile: Roboto (SDK default), tuned weights via `AppTheme`.
- Scale (web): page title 18–20 / card title 14–15 / body 13–13.5 / meta 12 / labels 11–11.5.
- Scale (mobile): headline 18–22 / title 14–15 / body 13.5–14 / meta 12 / caption 11.
- Weights: 800 for display numbers (scores, ETA), 700 for titles, 600 for labels/buttons.
- Uppercase only for micro-labels (ETA, PEOPLE, SOS SENT) with +0.3–2 px letter-spacing.

---

## 3. Shape, spacing, elevation

- **Card radius:** 12 px (small/compact) to 16 px (standard cards, sheets)
- **Button / field radius:** 10–12 px · **Chips/pills:** 999 px
- **Spacing scale:** 4 · 8 · 12 · 16 · 24 · 32 (mobile constants: `AppSpacing`)
- **Borders:** 1 px subtle; 2 px only for selected/active states
- **Elevation:** soft 10 px blur shadows only; dark mode uses `Colors.black26`,
  light mode uses `#142033 @ 6%` — never heavy drop shadows
- Bottom sheets: top radius 20–24 px with a 44×4.5 drag handle

---

## 4. Iconography

- **Web:** Lucide (`lucide-react`), stroke 2, sizes 13–22 px
- **Mobile:** Material Symbols (outlined default, rounded for emphasis), 16–34 px
- One icon concept per meaning — e.g. SOS always `sos`, flood always `water`,
  heatwave `thermostat`, quake `vibration` — on both platforms where possible.

---

## 5. Motion rules (restraint first)

- Durations: 150 ms (micro) · 250 ms (standard) · 400 ms (charts/containers)
- Curves: `easeOut`, `easeOutCubic` — never bouncy for operational UI
- **Pulse animation is reserved** for live/critical states only:
  critical alert dots, pending SOS, on-mission teams. Nothing decorative pulses.
- Splash: single 0.9 s fade-in + loading dots; 2.2 s total dwell.
- Charts animate once on mount; no looping data animation.

---

## 6. Component conventions

### Badges (severity/status)
Pill with 7 px leading dot + 11–11.5 px bold label, soft background at ~12–16% alpha.
Severity badge factory: `EgBadge.severity(level, context)` (mobile) /
`SeverityBadge` (web). Pulse dot only for unread-critical.

### Buttons
- Primary: accent bg, `onPrimary` text, 12 px radius, 700 weight
- Danger: emergency red — reserved for SOS/destructive
- Subtle: accent @ ~14% bg + accent text
- Ghost: transparent + 1.2 px outline
- Height ~44–50 px (mobile), 34–38 px (web compact)

### Cards
`EgCard` (mobile) / `.eg-card` (web): surface bg, 1 px border, 16 px radius,
16 px padding, soft shadow, optional tap. Never nest cards more than one level.

### Data rows / fact rows
Label left (secondary color) · value right (bold), 1 px dashed/solid divider below,
13 px type. IDs and codes in monospace.

---

## 7. Navigation patterns

### Mobile
Bottom bar: **Home · Map · ⬤SOS · Alerts · Profile** with 62 px red circular SOS FAB in a
center notch. IndexedStack keeps tab state. Badges show unread counts.
Full-screen pages (SOS, Rescue, Risk, Shelters, Assistant, Settings) push on top.

### Web
Sidebar groups: *Core* (Overview, Monitoring, Disasters, SOS), *Operations* (Teams, Risk,
Alerts, Shelters), *Administration* (Users, Reports, Map, Settings). Below 1024 px the
sidebar becomes an overlay drawer with scrim. Topbar keeps search, theme toggle, profile.

---

## 8. Charts & maps

- **Charts:** flat fills, 1 token-colored series unless comparing; bar radius 4–6;
  grid `#22334D`/`#E3EAF3`, dashed 3-3, horizontal only; tooltips = surface card
  with 12 px radius and 1 px border (no glow).
- **Pakistan map:** stylized CustomPainter (mobile) / SVG path (web), equirectangular
  projection, shared geo data. Severity-colored circle markers sized by severity
  (critical 9 → low 5.6 px), pulse rings for critical/high, selection ring + white core.
  Always pair with a legend; selectable markers must open a detail panel.

---

## 9. Accessibility & states

- Text contrast ≥ 4.5:1 on all body copy in both themes
- Interactive targets ≥ 44×44 px (mobile)
- Icon-only buttons carry tooltips/aria-labels
- Empty states: icon + one-line explanation (never blank panels)
- Loading: inline spinners (15–22 px) inside buttons/rows, not full-screen blockers
- Destructive/SOS actions confirm via hold (mobile) or explicit step (web)

---

## 10. Content voice

Plain, calm, operational English with Pakistan context (district names, Rescue 1122,
NDMA/PMD attributions). Numbers localized (`1.28 lakh`/`128K` style), times in PKT.
Never use alarm-red for non-critical UI chrome.
