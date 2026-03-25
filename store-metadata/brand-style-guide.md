# Split Fair — Brand Style Guide
**Version 1.0 | March 2026**

> "Split Fair is not a cute utility. It is a verdict machine. The design system should feel like the app already knows the answer and is waiting for you to catch up."

---

## 1. Brand Identity

### Brand Essence
Split Fair is a rent-splitting calculator for roommates that uses a points-based scoring system to calculate each person's fair share. The product's core promise is **mathematical fairness** — not a feeling, not a compromise, a number.

### Brand Personality
**Three words:** Direct. Witty. Authoritative.

### Brand North Star
**Google** — the color philosophy, not the logo. Google's multi-color system uses distinct, saturated hues (red, blue, yellow, green) against clean white or near-white backgrounds with no gradients. Each color is bold, unambiguous, and carries meaning. Split Fair applies this same logic with **green as the primary base**, extended with blue, amber/yellow, and red as secondary accents — matching Google's palette family without copying it.

Split Fair is not warm and supportive like a wellness app. It is not loud and playful like a gaming app. It is the voice of someone who has already done the math and is handing you the receipt — with a dry sense of humor about the fact that you even had to ask.

### Brand Tagline
**"Fair rent for every room."**

### Visual Direction
**Editorial / Magazine**

The aesthetic of a well-designed financial newspaper infographic: white space used aggressively, typography carries the weight, information is the hero. No decorative elements that don't earn their place. Think Monocle magazine meets fintech receipt — confident, legible, slightly austere.

---

## 2. Logo & Icon

### App Icon
- Balance scale icon on `#1D9E75` emerald green background
- Used as-is for all app icon contexts (iOS, Android, web favicon)
- Adaptive icon: green background `#1D9E75`, white foreground icon

### Logo Usage Rules
- Minimum size: 32px on digital, 8mm on print
- Clear space: equal to the height of the icon on all sides
- **Do not** recolor the icon — green background only
- **Do not** place on dark backgrounds without a white ring separator
- **Do not** stretch, skew, or apply drop shadows

### Wordmark
- "Split Fair" set in **Syne Bold** — the same font used for all headlines
- Letter-spacing: -0.02em (tight, confident)
- Two-tone option: **"Split"** in `#1A1A1A` dark + **"Fair"** in `#1D9E75` green — highlights the brand promise visually
- Color: `#1A1A1A` on light, `#F7F5F2` on dark

**Wordmark Options (3 generated, in D:\ProjectAssets\rent_split\images\canva\):**
- `wordmark_option_1.png` — Wordmark + balance scale icon, two-tone Split/Fair
- `wordmark_option_2.png` — Bold single-color wordmark, all green
- `wordmark_option_3.png` — Split Color, dark/green two-tone with separator symbol

---

## 3. Color System

### Primary Palette

| Name | Hex | Usage |
|------|-----|-------|
| **Emerald (Primary)** | `#1D9E75` | CTAs, key data callouts, "owed" figures, score bars, app icon background |
| **Deep Emerald** | `#157358` | Pressed/active states, text on tinted surfaces |
| **Emerald Tint** | `#E8F7F2` | Row highlight backgrounds, section fills, subtle surfaces |
| **Emerald Light** | `#A8E6CF` | Decorative accents, illustration fills |

### Neutral Palette

| Name | Hex | Usage |
|------|-----|-------|
| **Near Black** | `#1A1A1A` | Primary text — softer than pure black |
| **Dark Gray** | `#6B6B6B` | Secondary text, captions, labels |
| **Divider** | `#E8E5E0` | Row dividers, structural lines, screenshot design elements |
| **Surface** | `#F4F3F1` | Card backgrounds, list items, input fields |
| **Screen Background** | `#FFFFFF` | Main app screen background |
| **Screenshot Canvas** | `#F7F5F2` | Screenshot/marketing background — warmer than white, editorial feel |

### Accent Palette

| Name | Hex | Usage |
|------|-----|-------|
| **Amber (Alert)** | `#E5924A` | "You owe more" indicators, warnings — friendlier than red |
| **Destructive** | `#C0392B` | Delete actions, irreversible errors only — use sparingly |

### Room Colors (In-App Only)
Used for room/tenant color-coding in the app UI. These are never used in marketing materials.

`#1D9E75` `#378ADD` `#EF9F27` `#D85A30` `#7F77DD` `#D4537E` `#00897B` `#5C6BC0` `#0097A7` `#8D6E63`

### Color Rules
- **60% neutral** (whites, off-whites, grays), **30% emerald green**, **10% amber accent**
- Never use red for "owes money" states in social context — amber is the brand choice
- Green is a signal, not a decoration — reserve it for actionable and data moments
- Screenshot backgrounds: always `#F7F5F2`, never pure white, never gradients on background
- **Purple is explicitly banned** from all brand assets — no exceptions, no purple-adjacent colors
- Color inspiration = Google's palette logic: each color bold, unambiguous, no gradients

---

## 4. Typography

### Font Stack

| Role | Font | Weight | Where to Get |
|------|------|--------|--------------|
| **Display / Headlines** | Syne | ExtraBold (800), Bold (700) | [Google Fonts](https://fonts.google.com/specimen/Syne) |
| **Body / UI Copy** | DM Sans | Regular (400), Medium (500), SemiBold (600) | [Google Fonts](https://fonts.google.com/specimen/DM+Sans) |

**Flutter implementation:**
```dart
// pubspec.yaml — add google_fonts package
// Usage:
GoogleFonts.syne(fontWeight: FontWeight.w800)  // headlines
GoogleFonts.dmSans(fontWeight: FontWeight.w400) // body
```

**Why Syne:** Geometric confidence with editorial character — wider letterforms and subtle irregularities give it personality. Reads as design-literate without being pretentious. Distinctive vs. the Inter-saturated fintech space.

**Why DM Sans:** Shares Syne's geometric DNA but is warmer at body sizes. Slightly rounded corners and open apertures make it highly readable in small UI text and onboarding flows. Has tabular number support for balance displays.

**Alternative if Syne unavailable:** Outfit (Google Fonts) for headlines, DM Sans for body.

### Type Scale

| Context | Font | Weight | Size | Line Height | Letter Spacing |
|---------|------|--------|------|-------------|----------------|
| Screenshot hero headline | Syne | ExtraBold 800 | 52–60sp | 1.0 | -0.03em |
| Screenshot subheadline | DM Sans | SemiBold 600 | 18–22sp | 1.3 | 0 |
| App screen section title | Syne | Bold 700 | 28sp | 1.1 | -0.02em |
| App screen subheadline | Syne | SemiBold 600 | 20sp | 1.2 | -0.01em |
| UI body / room names | DM Sans | Regular 400 | 16sp | 1.5 | 0 |
| Secondary labels / captions | DM Sans | Medium 500 | 13sp | 1.4 | +0.01em |
| Score / amount callouts | Syne | ExtraBold 800 | 36–48sp | 1.0 | -0.03em |
| Fine print / disclaimers | DM Sans | Regular 400 | 11sp | 1.6 | +0.02em |
| Button labels | DM Sans | SemiBold 600 | 16sp | 1.0 | 0 |

**Key rule:** Dollar amounts and score figures always use Syne ExtraBold. Numbers rendered in a display font feel authoritative — that is the entire product promise.

### Typography Rules
- Headlines are flush left on screenshots — never centered (centered is a design crutch)
- Never mix more than two typefaces in any single asset
- All-caps usage: only for section labels at 11–12sp with +0.08em letter-spacing
- Font color on `#1D9E75` backgrounds: white only, never dark

---

## 5. App Store Screenshot Guidelines

### Dimensions
- **iOS (required):** 1290 × 2796px (iPhone 6.9" Pro Max)
- **Android (required):** 1080 × 1920px (minimum)
- **Format:** PNG, exported at pro quality via Canva

### Screenshot Strategy
Screenshots tell a 3-frame narrative. The first 3 screenshots carry the entire conversion story — 90% of users never reach screenshot 4.

| Frame | Purpose | Content |
|-------|---------|---------|
| 1 | **Emotional hook** | The problem — unfair splits, awkward conversations |
| 2 | **Hero UI** | The key differentiator — the scoring/fairness calculation |
| 3 | **The payoff** | Results screen — exact amounts, no ambiguity |
| 4 | **Retention feature** | Saved configs — roommates change, the math doesn't |
| 5 | **Monetization** | PDF export unlock — $1.99, one-time |

### Approved Screenshot Headlines

| Slot | Headline | Font | Notes |
|------|---------|------|-------|
| 1 | **Split it fair.** | Syne ExtraBold 800 | States the app name, period lands like a verdict |
| 2 | **Dave's room costs more.** | Syne ExtraBold 800 | Specific and funny — calls out the injustice directly |
| 3 | **No more guessing.** | Syne ExtraBold 800 | Implies prior frustration, feels like relief |
| 4 | **Roommates change. Math doesn't.** | Syne ExtraBold 800 | Keep exactly as-is — best line in the set |
| 5 | **Print the proof.** | Syne ExtraBold 800 | Alliterative, implies finality and math-backed authority |

**Alternate for Slot 2:** "Yes, that closet counts." — pulls directly from the onboarding voice and is slightly funnier.

### Screenshot Layout Rules
- **Headline:** Top third, flush left, `#1A1A1A` on `#F7F5F2` background
- **App frame:** Bottom 60%, slightly cropped to imply there's more
- **Background:** `#F7F5F2` (warm off-white) — never pure white, never gradients
- **Accent:** Single thin `#1D9E75` horizontal rule (1–2px) as header separator
- **Texture (optional):** Subtle noise overlay at 4–8% opacity for "printed document" feel
- **No device chrome** (phone frame bezels) — the UI is the frame

### Screenshot Character Count Rules
- Hero headline: max 35 characters (single line, no wrapping)
- Subheadline / supporting text: max 60 characters
- No body copy on screenshots — let the UI speak

---

## 6. Brand Voice & Copy

### Voice Attributes
- **Direct:** says exactly what it means, no filler
- **Witty:** earns the laugh with specifics, not adjectives
- **Authoritative:** the app knows the answer; it's not asking for permission
- **Empathetic:** validates the user's frustration without being a therapist about it

### Copy DO ✅

| Example | Why It Works |
|---------|-------------|
| "Dave's room has a window, a closet, and your patience." | Specific and relatable. Validates the frustration. |
| "Score the room. Split the bill. Move on." | Imperative, staccato, respects the user's time. |
| "Your math is right. Now show them." | Empowers the user. The results are receipts, not suggestions. |
| "Smaller room. Smaller share. Obviously." | "Obviously" signals shared understanding — the app is on your side. |
| "You've been overpaying. We just proved it." | Past tense makes it feel like discovery, not accusation. |

### Copy DON'T ❌

| Example | Why It Fails |
|---------|-------------|
| "Split rent fairly with your roommates today!" | Exclamation mark + "today!" = ad copy. Destroys trust. |
| "Our powerful algorithm calculates the perfect split." | "Powerful algorithm" is used by every app with a for-loop. |
| "Making roommate life easier." | Vague mission statement. "Easier" means nothing here. |
| "Collaborate with your roommates on rent!" | "Collaborate" is B2B SaaS language. Roommates argue, then settle. |
| "We care about fairness." | Any "we care about X" sentence is automatically suspicious. Show it, don't claim it. |

### Headline Formula
**[Specific injustice or frustration] + [blunt resolution or revelation]**

Examples:
- "Dave's room costs more. Now he pays more."
- "You measured the rooms. We did the math."
- "Fair split in 60 seconds."

### Copy Length Rules
- App Store description: conversational, benefit-led paragraphs, no bullet-point walls
- Screenshot text: headline only, max 6 words — UI is the body copy
- Push notifications (if added): max 10 words, always actionable
- Error messages: plain language, no jargon, one suggested action

---

## 7. Imagery & Illustration

### In-App Illustration Style
- Icon-based (Material Icons + custom SVG) — no photographic imagery in-app
- Illustrations use the brand color palette only
- Room color avatars: single letter initial in a colored circle — simple, scalable

### Marketing / Social Imagery

**Direction: Real people, golden hour, living spaces**

- **Subjects:** Young adults (20s–30s), racially and stylistically diverse — different backgrounds, personal styles, natural looks. No model-polished aesthetics.
- **Setting:** Living rooms, apartments — where rent conversations actually happen. Games in the space: pool table, ping pong, board games. Casual, social, at-home.
- **Lighting:** Golden hour — warm, directional, window light or late-afternoon sun. Shallow depth of field, crisp subject focus, soft background bokeh.
- **Mood:** Smiling, laughing, having fun. The app removes the tension — the photos should show the relief. Not staged awkward roommate tension.
- **Never use:** Stock photo aesthetics, staged corporate diversity, flat studio lighting, solid-color backgrounds behind people.

**Shot list for campaigns:**
1. Group of 3–4 roommates in a living room, one person showing the app on their phone — others reacting positively
2. Close-up of a phone screen showing the results screen, warm golden light, a hand holding it
3. Two people at a table, laughing, a coffee or drink in frame — app calculation visible
4. Wide shot of a furnished apartment living room — golden hour through windows, no people, establishing shot
5. Overhead of a coffee table with phones, snacks, a game — lived-in apartment feel

### Icon Style (Marketing Assets)
- Filled, rounded corners, single-weight stroke
- Color: `#1D9E75` on white, white on `#1D9E75`
- Never use emoji as icons in any branded asset

---

## 8. Layout & Spacing

### Base Grid
- **Base unit:** 8px
- **Screen margins:** 20px (matches app implementation)
- **Card padding:** 16–20px
- **Section spacing:** 24px between sections
- **Marketing asset grid:** 12-column, 1rem gutters

### Spacing Scale
`4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 · 64 · 80 · 96`

### Border Radius Scale
- Small (chips, badges): 6px
- Medium (cards, inputs): 14–16px
- Large (sheets, modals): 24px top corners
- Full (avatars, tags): 999px

---

## 9. Platform-Specific Rules

### iOS App Store
- Screenshots: 1290 × 2796px PNG
- App name: "Split Fair" (30 char max ✅)
- Subtitle: "Fair rent for every roommate" (30 char max ✅)
- Category: Finance (primary), Utilities (secondary)

### Google Play Store
- Feature graphic: 1024 × 500px
- Screenshots: minimum 1080 × 1920px
- App name: "Split Fair — Rent Calculator" (50 char max ✅)
- Category: Finance

### Social Media
*(Pending platform decisions from user)*
- Recommended: Instagram (apartment/lifestyle audience), Reddit (r/personalfinance, r/lifehacks)
- Aspect ratios: 1:1 for feed, 9:16 for Stories/Reels
- All social assets use `#F7F5F2` background or `#1D9E75` solid fill

---

## 10. What We're Still Missing

The following require answers from the founder before this guide is fully locked:

| # | Question | Status |
|---|---------|--------|
| 1 | 3 words describing the brand personality | ✅ Direct. Witty. Authoritative. |
| 2 | Brands/apps whose visual identity you admire | ✅ Google — multi-color palette, clean backgrounds |
| 3 | Colors to explicitly avoid | ✅ Purple — banned entirely |
| 4 | Photography/imagery style preference | ✅ See Section 7 — golden hour, diverse young adults, living room games |
| 5 | Wordmark/logo direction | ✅ 3 options generated in Canva — see canva folder |
| 6 | Platforms beyond App Store and Play Store | ⚠️ Not yet answered |

---

## 11. Asset Checklist

### App Store (iOS)
- [ ] Screenshot 1 — "Split it fair." (rooms list)
- [ ] Screenshot 2 — "Dave's room costs more." (scoring)
- [ ] Screenshot 3 — "No more guessing." (results)
- [ ] Screenshot 4 — "Roommates change. Math doesn't." (saved configs)
- [ ] Screenshot 5 — "Print the proof." (PDF export)
- [ ] App icon 1024 × 1024px
- [ ] Privacy policy URL

### Google Play Store
- [ ] Feature graphic 1024 × 500px
- [ ] Screenshots (5 minimum)
- [ ] App icon 512 × 512px
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)

### Brand Assets
- [ ] Wordmark lockup (Syne Bold + icon)
- [ ] Social profile icon (square, 1:1)
- [ ] Social banner (16:9)
- [ ] Dark mode variants of all above

---

*Style guide produced from: competitive market research (Splitwise, Tricount, Settle Up), ui-ux-pro-max design system analysis, and bencium-innovative-ux-designer evaluation. All asset creation going forward must reference this document.*
