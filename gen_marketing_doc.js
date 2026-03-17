const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  AlignmentType, HeadingLevel, BorderStyle, WidthType, ShadingType,
  VerticalAlign, PageNumber, Header, Footer, PageBreak, TabStopType,
  TabStopPosition, LevelFormat
} = require('docx');
const fs = require('fs');

// ─── Color palette ───────────────────────────────────────────────────────────
const GREEN       = '1D9E75';
const GREEN_DARK  = '0F6E56';
const GREEN_LIGHT = 'E1F5EE';
const AMBER       = 'EF9F27';
const AMBER_LIGHT = 'FDF3E0';
const WHITE       = 'FFFFFF';
const GRAY_LIGHT  = 'F8F9FA';
const GRAY_MED    = 'E8EAED';
const GRAY_TEXT   = '6B7280';
const BLACK       = '1A1D23';

// ─── Helpers ─────────────────────────────────────────────────────────────────
const border = (color = GRAY_MED) => ({ style: BorderStyle.SINGLE, size: 1, color });
const borders = (color = GRAY_MED) => ({ top: border(color), bottom: border(color), left: border(color), right: border(color) });
const noBorder = () => ({ style: BorderStyle.NONE, size: 0, color: WHITE });
const noBorders = () => ({ top: noBorder(), bottom: noBorder(), left: noBorder(), right: noBorder() });

const sp = (before = 0, after = 0) => ({ spacing: { before, after } });

function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    ...sp(320, 120),
    children: [new TextRun({ text, font: 'Arial', size: 36, bold: true, color: GREEN_DARK })]
  });
}

function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    ...sp(280, 80),
    children: [new TextRun({ text, font: 'Arial', size: 28, bold: true, color: GREEN })]
  });
}

function h3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    ...sp(200, 60),
    children: [new TextRun({ text, font: 'Arial', size: 24, bold: true, color: BLACK })]
  });
}

function body(text, opts = {}) {
  return new Paragraph({
    ...sp(60, 60),
    children: [new TextRun({ text, font: 'Arial', size: 22, color: BLACK, ...opts })]
  });
}

function label(text) {
  return new Paragraph({
    ...sp(40, 20),
    children: [new TextRun({ text: text.toUpperCase(), font: 'Arial', size: 18, bold: true, color: GRAY_TEXT, characterSpacing: 40 })]
  });
}

function bullet(text, indent = 360) {
  return new Paragraph({
    numbering: { reference: 'bullets', level: 0 },
    ...sp(40, 40),
    indent: { left: indent, hanging: 220 },
    children: [new TextRun({ text, font: 'Arial', size: 22, color: BLACK })]
  });
}

function rule(color = GREEN_LIGHT) {
  return new Paragraph({
    ...sp(80, 80),
    border: { bottom: { style: BorderStyle.SINGLE, size: 4, color, space: 1 } },
    children: []
  });
}

function spacer(before = 160) {
  return new Paragraph({ ...sp(before, 0), children: [] });
}

// Call-out box (green background)
function callout(lines, bgColor = GREEN_LIGHT, textColor = GREEN_DARK) {
  const cellBorderColor = bgColor === GREEN_LIGHT ? '99D6C0' : 'D4A843';
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [
      new TableRow({
        children: [
          new TableCell({
            borders: borders(cellBorderColor),
            width: { size: 9360, type: WidthType.DXA },
            shading: { fill: bgColor, type: ShadingType.CLEAR },
            margins: { top: 160, bottom: 160, left: 200, right: 200 },
            children: lines.map((line, i) => new Paragraph({
              ...sp(i === 0 ? 0 : 40, i === lines.length - 1 ? 0 : 40),
              children: [new TextRun({
                text: line,
                font: 'Courier New',
                size: 18,
                color: textColor,
              })]
            }))
          })
        ]
      })
    ]
  });
}

// Info box (label + body text, amber)
function infoBox(title, text) {
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [
      new TableRow({
        children: [
          new TableCell({
            borders: borders('F5C96A'),
            width: { size: 9360, type: WidthType.DXA },
            shading: { fill: AMBER_LIGHT, type: ShadingType.CLEAR },
            margins: { top: 140, bottom: 140, left: 200, right: 200 },
            children: [
              new Paragraph({
                ...sp(0, 60),
                children: [new TextRun({ text: title, font: 'Arial', size: 20, bold: true, color: '7A4E00' })]
              }),
              new Paragraph({
                ...sp(0, 0),
                children: [new TextRun({ text, font: 'Arial', size: 20, color: '5A3800' })]
              })
            ]
          })
        ]
      })
    ]
  });
}

// 2-col table
function twoColTable(rows, headers) {
  const hdrBorder = borders('99D6C0');
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [3000, 6360],
    rows: [
      ...(headers ? [new TableRow({
        tableHeader: true,
        children: headers.map((h, i) => new TableCell({
          borders: hdrBorder,
          width: { size: i === 0 ? 3000 : 6360, type: WidthType.DXA },
          shading: { fill: GREEN, type: ShadingType.CLEAR },
          margins: { top: 100, bottom: 100, left: 140, right: 140 },
          children: [new Paragraph({ children: [new TextRun({ text: h, font: 'Arial', size: 20, bold: true, color: WHITE })] })]
        }))
      })] : []),
      ...rows.map(([a, b]) => new TableRow({
        children: [
          new TableCell({
            borders: borders(GRAY_MED),
            width: { size: 3000, type: WidthType.DXA },
            shading: { fill: GREEN_LIGHT, type: ShadingType.CLEAR },
            margins: { top: 80, bottom: 80, left: 140, right: 140 },
            children: [new Paragraph({ children: [new TextRun({ text: a, font: 'Arial', size: 20, bold: true, color: GREEN_DARK })] })]
          }),
          new TableCell({
            borders: borders(GRAY_MED),
            width: { size: 6360, type: WidthType.DXA },
            margins: { top: 80, bottom: 80, left: 140, right: 140 },
            children: [new Paragraph({ children: [new TextRun({ text: b, font: 'Arial', size: 20, color: BLACK })] })]
          })
        ]
      }))
    ]
  });
}

// 4-col competitor table
function competitorTable() {
  const cols = [2200, 2200, 2760, 2200];
  const hdrs = ['Competitor', 'Type', 'Weakness', 'Our Angle'];
  const rows = [
    ['Splitwise', 'General expense tracker', 'Free tier daily limits, no room scoring', '"Built for rent, not expenses"'],
    ['Spliddit', 'Web-only calculator', 'No mobile app, academic UI', '"Native app, beautiful results"'],
    ['Fair Rent Splitter', 'Web calculator', 'No native app, vague factors', '"Transparent algorithm, every point explained"'],
    ['Tricount', 'Expense splitting', 'No room weighting at all', '"Accounts for room differences"'],
  ];
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: cols,
    rows: [
      new TableRow({
        tableHeader: true,
        children: hdrs.map((h, i) => new TableCell({
          borders: borders('99D6C0'),
          width: { size: cols[i], type: WidthType.DXA },
          shading: { fill: GREEN_DARK, type: ShadingType.CLEAR },
          margins: { top: 100, bottom: 100, left: 120, right: 120 },
          children: [new Paragraph({ children: [new TextRun({ text: h, font: 'Arial', size: 20, bold: true, color: WHITE })] })]
        }))
      }),
      ...rows.map(([a, b, c, d]) => new TableRow({
        children: [a, b, c, d].map((text, i) => new TableCell({
          borders: borders(GRAY_MED),
          width: { size: cols[i], type: WidthType.DXA },
          shading: { fill: i === 0 ? GREEN_LIGHT : WHITE, type: ShadingType.CLEAR },
          margins: { top: 80, bottom: 80, left: 120, right: 120 },
          children: [new Paragraph({ children: [new TextRun({ text, font: 'Arial', size: 20, color: i === 0 ? GREEN_DARK : BLACK, bold: i === 0 })] })]
        }))
      }))
    ]
  });
}

// Social media platform table (4 cols)
function platformTable() {
  const cols = [2000, 2400, 2760, 2200];
  const hdrs = ['Platform', 'Format', 'Audience', 'Cadence'];
  const rows = [
    ['Instagram', 'Carousels + Reels', 'Ages 22–34, apartment hunters', '3–4x / week'],
    ['TikTok', 'Screen recordings + POV hooks', 'Ages 18–28, new grads', 'Daily May–Sep, 3x/week off-season'],
    ['Twitter / X', 'Screenshots + threads', 'Personal finance crowd', '2x / day'],
  ];
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: cols,
    rows: [
      new TableRow({
        tableHeader: true,
        children: hdrs.map((h, i) => new TableCell({
          borders: borders('99D6C0'),
          width: { size: cols[i], type: WidthType.DXA },
          shading: { fill: GREEN, type: ShadingType.CLEAR },
          margins: { top: 100, bottom: 100, left: 120, right: 120 },
          children: [new Paragraph({ children: [new TextRun({ text: h, font: 'Arial', size: 20, bold: true, color: WHITE })] })]
        }))
      }),
      ...rows.map(([a, b, c, d]) => new TableRow({
        children: [a, b, c, d].map((text, i) => new TableCell({
          borders: borders(GRAY_MED),
          width: { size: cols[i], type: WidthType.DXA },
          shading: { fill: i === 0 ? GREEN_LIGHT : WHITE, type: ShadingType.CLEAR },
          margins: { top: 80, bottom: 80, left: 120, right: 120 },
          children: [new Paragraph({ children: [new TextRun({ text, font: 'Arial', size: 20, color: i === 0 ? GREEN_DARK : BLACK, bold: i === 0 })] })]
        }))
      }))
    ]
  });
}

// Screenshot spec row
function screenshotRow(num, title, headline, subtext, extra) {
  const cols = [1200, 8160];
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: cols,
    rows: [new TableRow({
      children: [
        new TableCell({
          borders: borders(GREEN),
          width: { size: 1200, type: WidthType.DXA },
          shading: { fill: GREEN, type: ShadingType.CLEAR },
          margins: { top: 120, bottom: 120, left: 120, right: 120 },
          verticalAlign: VerticalAlign.CENTER,
          children: [new Paragraph({
            alignment: AlignmentType.CENTER,
            children: [new TextRun({ text: num, font: 'Arial', size: 40, bold: true, color: WHITE })]
          })]
        }),
        new TableCell({
          borders: borders(GRAY_MED),
          width: { size: 8160, type: WidthType.DXA },
          shading: { fill: WHITE, type: ShadingType.CLEAR },
          margins: { top: 120, bottom: 120, left: 180, right: 180 },
          children: [
            new Paragraph({ ...sp(0, 40), children: [new TextRun({ text: title, font: 'Arial', size: 22, bold: true, color: GREEN_DARK })] }),
            new Paragraph({ ...sp(0, 30), children: [new TextRun({ text: `Headline: "${headline}"`, font: 'Arial', size: 20, italic: true, color: BLACK })] }),
            new Paragraph({ ...sp(0, extra ? 30 : 0), children: [new TextRun({ text: `Sub-text: "${subtext}"`, font: 'Arial', size: 20, color: GRAY_TEXT })] }),
            ...(extra ? [new Paragraph({ ...sp(0, 0), children: [new TextRun({ text: extra, font: 'Arial', size: 20, color: GRAY_TEXT })] })] : [])
          ]
        })
      ]
    })]
  });
}

// Cover page header block
function coverBlock() {
  return new Table({
    width: { size: 9360, type: WidthType.DXA },
    columnWidths: [9360],
    rows: [new TableRow({
      children: [new TableCell({
        borders: noBorders(),
        width: { size: 9360, type: WidthType.DXA },
        shading: { fill: GREEN_DARK, type: ShadingType.CLEAR },
        margins: { top: 480, bottom: 480, left: 400, right: 400 },
        children: [
          new Paragraph({
            alignment: AlignmentType.LEFT,
            ...sp(0, 80),
            children: [new TextRun({ text: 'Split Fair', font: 'Arial', size: 64, bold: true, color: WHITE })]
          }),
          new Paragraph({
            alignment: AlignmentType.LEFT,
            ...sp(0, 120),
            children: [new TextRun({ text: 'Marketing Strategy & Creative Assets', font: 'Arial', size: 32, color: 'A8DFD0' })]
          }),
          new Paragraph({
            alignment: AlignmentType.LEFT,
            ...sp(0, 0),
            children: [
              new TextRun({ text: 'Brand: Split Fair  ', font: 'Arial', size: 20, color: 'A8DFD0' }),
              new TextRun({ text: '|  ', font: 'Arial', size: 20, color: '5BBFA8' }),
              new TextRun({ text: 'Tagline: Fair rent for every room  ', font: 'Arial', size: 20, color: 'A8DFD0' }),
              new TextRun({ text: '|  ', font: 'Arial', size: 20, color: '5BBFA8' }),
              new TextRun({ text: 'March 2026', font: 'Arial', size: 20, color: 'A8DFD0' }),
            ]
          })
        ]
      })]
    })]
  });
}

// ─── Document ────────────────────────────────────────────────────────────────
const doc = new Document({
  numbering: {
    config: [
      {
        reference: 'bullets',
        levels: [{
          level: 0, format: LevelFormat.BULLET, text: '\u2022', alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 440, hanging: 220 } } }
        }]
      },
      {
        reference: 'check',
        levels: [{
          level: 0, format: LevelFormat.BULLET, text: '\u25A1', alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 440, hanging: 220 } } }
        }]
      }
    ]
  },
  styles: {
    default: {
      document: { run: { font: 'Arial', size: 22, color: BLACK } }
    },
    paragraphStyles: [
      { id: 'Heading1', name: 'Heading 1', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 36, bold: true, font: 'Arial', color: GREEN_DARK },
        paragraph: { spacing: { before: 320, after: 120 }, outlineLevel: 0 } },
      { id: 'Heading2', name: 'Heading 2', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 28, bold: true, font: 'Arial', color: GREEN },
        paragraph: { spacing: { before: 280, after: 80 }, outlineLevel: 1 } },
      { id: 'Heading3', name: 'Heading 3', basedOn: 'Normal', next: 'Normal', quickFormat: true,
        run: { size: 24, bold: true, font: 'Arial', color: BLACK },
        paragraph: { spacing: { before: 200, after: 60 }, outlineLevel: 2 } },
    ]
  },
  sections: [{
    properties: {
      page: {
        size: { width: 12240, height: 15840 },
        margin: { top: 1080, right: 1080, bottom: 1080, left: 1080 }
      }
    },
    headers: {
      default: new Header({
        children: [new Paragraph({
          border: { bottom: { style: BorderStyle.SINGLE, size: 4, color: GREEN, space: 1 } },
          tabStops: [{ type: TabStopType.RIGHT, position: TabStopPosition.MAX }],
          children: [
            new TextRun({ text: 'Split Fair  —  Marketing Strategy', font: 'Arial', size: 18, color: GRAY_TEXT }),
            new TextRun({ text: '\tMarch 2026', font: 'Arial', size: 18, color: GRAY_TEXT }),
          ]
        })]
      })
    },
    footers: {
      default: new Footer({
        children: [new Paragraph({
          border: { top: { style: BorderStyle.SINGLE, size: 4, color: GREEN_LIGHT, space: 1 } },
          alignment: AlignmentType.RIGHT,
          children: [
            new TextRun({ text: 'Page ', font: 'Arial', size: 18, color: GRAY_TEXT }),
            new TextRun({ children: [PageNumber.CURRENT], font: 'Arial', size: 18, color: GREEN }),
          ]
        })]
      })
    },
    children: [

      // ── COVER ──────────────────────────────────────────────────────────────
      coverBlock(),
      spacer(200),

      // ── 1. BRAND VOICE ──────────────────────────────────────────────────────
      h1('01  Brand Voice'),
      rule(),
      body('Tone direction: Editorial / Utilitarian with warmth', { bold: true }),
      spacer(60),
      body('Rent splitting is awkward and emotional — but math is objective. Split Fair makes an uncomfortable roommate conversation into an undeniable fact. The voice is confident, slightly dry, and smart, like a friend who happened to get a math degree.'),
      spacer(100),
      label('Tagline options to A/B test'),
      bullet('"Fair rent for every room"  (current — clear and direct)'),
      bullet('"No one can argue with math"'),
      bullet('"The algorithm your roommates will actually agree to"'),
      bullet('"Split it. Prove it. Move on."'),

      spacer(200),

      // ── 2. APP ICON ──────────────────────────────────────────────────────────
      new Paragraph({ children: [new PageBreak()] }),
      h1('02  App Icon'),
      rule(),
      h3('Light Variant  (Primary — App Store submission)'),
      spacer(40),
      callout([
        'Minimalist iOS app icon, 1024x1024 pixels.',
        'Background: clean white (#FFFFFF) with large rounded corners.',
        '',
        'Center: stylized house silhouette split in two halves.',
        '  Left half:  solid #1D9E75 (medium green)',
        '  Right half: solid #0F6E56 (darker green)',
        '  Divider:    crisp white vertical line, 3px, roof peak to base.',
        '',
        'House shape: geometric flat — square base, inverted-V roof.',
        'No windows, no doors, no details. Pure silhouette.',
        'House height: ~55% of canvas. Thin green drop shadow (20% opacity).',
        '',
        'No text. No gradients. No 3D. Flat, Material Design-adjacent.',
        'App Store ready. Vector-clean look.',
      ]),
      spacer(120),
      h3('Dark Variant  (A/B Test)'),
      spacer(40),
      callout([
        'Background: deep forest green (#0F6E56).',
        'House: white left half, off-white (#F0FAF6) right half.',
        'Divider: thin amber (#EF9F27) vertical line.',
        'Clean, premium, high contrast.',
      ], AMBER_LIGHT, '5A3800'),

      spacer(200),

      // ── 3. APP STORE LISTING ─────────────────────────────────────────────────
      new Paragraph({ children: [new PageBreak()] }),
      h1('03  App Store Listing'),
      rule(),

      label('Short Description  (30 chars)'),
      spacer(40),
      infoBox('Copy-paste ready', 'Fair rent splits, explained.'),
      spacer(120),

      label('ASO Keywords'),
      body('rent split  •  roommate calculator  •  fair rent  •  rent divider  •  room split  •  apartment split  •  roommate app  •  rent calculator  •  fair split  •  room calculator'),
      spacer(120),

      label('Full Description'),
      spacer(40),
      callout([
        'SPLIT FAIR — Fair Rent for Every Room',
        '',
        'Stop guessing. Stop arguing. Get the number everyone can actually agree on.',
        '',
        'Split Fair calculates fair rent splits using a transparent scoring algorithm',
        '— not just equal splits or rough percentages. Every point is explained.',
        '',
        'HOW IT WORKS',
        '  • Square footage         (every sqft = 1 pt)',
        '  • Private bathroom       (+40 pts)',
        '  • Parking spot           (+30 pts)',
        '  • Balcony or patio       (+20 pts)',
        '  • Walk-in closet         (+15 pts)',
        '  • A/C unit               (+10 pts)',
        '  • Floor level bonus      (up to +12 pts)',
        '  • Natural light slider   (×3 pts each)',
        '  • Noise level slider     (×2 pts each)',
        '  • Storage space slider   (×1.5 pts each)',
        '',
        'FEATURES',
        '  ✓ Up to 6 rooms per calculation',
        '  ✓ Live score breakdown — updates as you adjust',
        '  ✓ Animated results with donut chart visual',
        '  ✓ "Why these numbers?" transparency card',
        '  ✓ "How scoring works" full explainer sheet',
        '  ✓ Share results as text to your roommates',
        '  ✓ Copy to clipboard',
        '  ✓ Property address saved with calculations',
        '  ✓ All data saved locally — no account needed',
        '',
        'UNLOCK PDF EXPORT — $1.99 one-time',
        '  Professional, printable PDF. Perfect for lease negotiations.',
        '',
        'UNLOCK SAVED CONFIGS — $1.99 one-time',
        '  Save up to 10 room configurations. Switch between them instantly.',
        '',
        'WHY NOT SPLITWISE?',
        '  Splitwise is great for ongoing expenses. Split Fair is built for one',
        '  specific problem: who pays how much for which room.',
        '  No transaction limits. No subscription. No account required.',
        '',
        'Split Fair. The algorithm your roommates will actually agree to.',
      ]),

      spacer(200),

      // ── 4. SCREENSHOTS ───────────────────────────────────────────────────────
      new Paragraph({ children: [new PageBreak()] }),
      h1('04  App Store Screenshots'),
      rule(),
      infoBox('Technical spec', 'iPhone 15 Pro Max required: 1290 × 2796 px. Create all 5 at this size before submission.'),
      spacer(120),

      screenshotRow('1', 'Hero', 'Fair rent. Instantly.', 'Enter your rooms. Get the split everyone agrees to.', 'Background: clean white with subtle green geometric accent'),
      spacer(80),
      screenshotRow('2', 'The Algorithm', 'Every point explained.', 'See exactly why each room costs what it does. No black box.', 'Callout: arrow pointing to score counter — "Updates live as you adjust"'),
      spacer(80),
      screenshotRow('3', 'Results', 'The math nobody can argue with.', 'Animated breakdown. Share as text, copy, or export a PDF.', 'Show donut chart + amounts counting up'),
      spacer(80),
      screenshotRow('4', 'Transparency', 'Show your work.', 'Full score transparency. Your roommates see the logic, not just the number.', 'Show "Why these numbers?" card expanded'),
      spacer(80),
      screenshotRow('5', 'Saved Configs', 'Comparing apartments? Save each one.', 'Save up to 10 room setups and switch between them instantly.', 'Show configs sheet with named setups listed'),

      spacer(200),

      // ── 5. SOCIAL MEDIA ──────────────────────────────────────────────────────
      new Paragraph({ children: [new PageBreak()] }),
      h1('05  Social Media Strategy'),
      rule(),

      h2('Platform Overview'),
      spacer(40),
      platformTable(),
      spacer(160),

      h2('Pain Points  →  Hook Angles'),
      spacer(40),
      twoColTable([
        ['"My roommate\'s room is bigger but we pay the same"', 'The sqft algorithm — show the math'],
        ['"My room has no windows and theirs has a balcony"', 'Feature bonuses (+20 pts balcony)'],
        ['"Nobody agrees on what\'s fair"', 'Transparent scoring — every point shown'],
        ['"Splitwise limits free users now"', 'Free calculator, no limits, no account'],
        ['"I just have a screenshot from a group chat"', 'Professional PDF export'],
        ['"We\'re looking at 3 apartments"', 'Saved configurations feature'],
      ], ['Pain Point', 'Hook Angle']),

      spacer(200),

      // ── 6. POST CONCEPTS ─────────────────────────────────────────────────────
      new Paragraph({ children: [new PageBreak()] }),
      h1('06  Post Concepts'),
      rule(),

      // Post 1
      h2('Post 1  —  TikTok / Reels'),
      infoBox('Hook overlay text', 'POV: you finally have receipts'),
      spacer(80),
      label('Visual Direction'),
      body('Screen recording. Open room edit sheet. Type "Master bedroom" — 220 sqft. Toggle Private Bath on (+40 pts). Drag Natural Light slider to 9. Cut to results screen — amounts count up. Roommate\'s amount is $280 more. Freeze frame. Text overlay: "That\'s not an opinion. That\'s math."'),
      spacer(80),
      label('Caption'),
      callout([
        'the algorithm does NOT care about feelings 📊',
        '',
        'Room 1: 220sqft + private bath + good light = 312 pts',
        'Room 2: 140sqft + shared bath + faces the alley = 195 pts',
        '',
        'why would you split that equally?',
        '',
        'Split Fair — free on the App Store ✓',
        '#roommate #rent #apartments #movingout #adulting',
      ]),
      spacer(80),
      label('Why It Works'),
      body('Satisfying reveal, relatable conflict, positions the app as a neutral arbiter. Designed to be duet-able and screenshot-shareable.'),

      spacer(160),

      // Post 2
      h2('Post 2  —  Instagram Carousel'),
      infoBox('Format', '6-slide carousel — swipe-through educational content'),
      spacer(80),
      label('Slide Breakdown'),
      twoColTable([
        ['Slide 1', '"Splitting rent equally is almost always unfair." — Bold white text on dark green background'],
        ['Slide 2', '"Square footage matters more than you think" — two room sizes, same price crossed out'],
        ['Slide 3', '"A private bathroom adds $40–$80/month of value" — feature chip visual from app'],
        ['Slide 4', '"Natural light, noise level, storage? All quantifiable." — three sliders shown'],
        ['Slide 5', '"Here\'s what fair actually looks like" — results screen screenshot'],
        ['Slide 6', '"One algorithm. Zero arguments." — download CTA'],
      ], ['Slide', 'Content']),
      spacer(80),
      label('Caption'),
      callout([
        'your roommate\'s room might genuinely be worth more than yours.',
        'or less. either way — you deserve to know the math.',
        '',
        'Split Fair calculates fair rent splits based on actual room value:',
        'sqft, private bath, balcony, natural light, noise, storage, and more.',
        '',
        'free to use. share the results. no more guessing.',
        '',
        '🔗 link in bio',
        '#renttips #roommatelife #apartment #personalfinance #fairrent #movingday',
      ]),

      spacer(160),

      // Post 3
      h2('Post 3  —  Twitter / X Educational Thread'),
      spacer(40),
      twoColTable([
        ['Tweet 1', 'Equal rent splits are almost never fair. Here\'s the math most roommates are getting wrong (🧵):'],
        ['Tweet 2', 'Room A: 200 sqft, private bath, balcony, good light. Room B: 140 sqft, shared bath, faces a wall. "50/50" = both pay $1,500. That\'s not fair. That\'s just easy.'],
        ['Tweet 3', 'Room A: 200+40+20+27 = 287 pts. Room B: 140+15 = 155 pts. Score weights: sqft×1, bath+40, balcony+20, closet+15, natural light×3 each.'],
        ['Tweet 4', 'Total 442 pts. Room A: 64.9% → $1,947/mo. Room B: 35.1% → $1,053/mo. That\'s a $447/month difference on a "50/50" split.'],
        ['Tweet 5', 'Built an app that does all this. Every number shown. Exportable PDF. Your roommates can\'t argue with the math. Free: [App Store link]'],
      ], ['Tweet', 'Copy']),

      spacer(200),

      // ── 7. COMPETITIVE POSITIONING ───────────────────────────────────────────
      new Paragraph({ children: [new PageBreak()] }),
      h1('07  Competitive Positioning'),
      rule(),
      competitorTable(),

      spacer(200),

      // ── 8. IMAGE GENERATION PROMPTS ──────────────────────────────────────────
      h1('08  Image Generation Prompts'),
      rule(),
      body('Use these prompts with Adobe Firefly, DALL-E 3, or Ideogram. Copy exactly for best results.'),
      spacer(80),

      h3('Hero Marketing Image  —  Social Posts'),
      callout([
        'Clean, modern product marketing image for a mobile app called "Split Fair".',
        'Flat lay style. Two smartphone screens side by side on a white surface.',
        'Left phone: room settings screen with green sliders and feature chips.',
        'Right phone: results screen with a green donut chart and dollar amounts.',
        'Accent color: #1D9E75 green. Background: off-white #F8F9FA.',
        'Soft shadows under phones. No text overlay.',
        'Professional product photography aesthetic. Minimalist, editorial. No people.',
      ]),
      spacer(80),

      h3('Lifestyle Shot  —  Instagram'),
      callout([
        'Realistic lifestyle photo. Two young adults (early 20s, gender neutral)',
        'sitting at a kitchen table in a modern apartment, looking at a phone together.',
        'One person is smiling, the other looks relieved.',
        'The phone shows a green app UI with numbers.',
        'Natural window light from the left. Warm, inviting apartment interior.',
        'Candid, authentic feel. No staged poses.',
      ]),
      spacer(80),

      h3('Abstract Algorithm Visual  —  Twitter Header  (16:9)'),
      callout([
        'Abstract data visualization. Dark forest green background (#0F6E56).',
        'Floating geometric shapes: rooms as white rectangles of different sizes.',
        'Thin connecting lines flow from rooms to a central split point.',
        'Numbers float as white text: +40, +20, 220 sqft.',
        'A donut chart in amber (#EF9F27) in the center.',
        'Clean, editorial, tech-forward. 16:9 ratio. No app name text.',
      ]),

      spacer(200),

      // ── 9. LAUNCH TIMELINE ───────────────────────────────────────────────────
      new Paragraph({ children: [new PageBreak()] }),
      h1('09  Launch Timeline'),
      rule(),
      twoColTable([
        ['Week 1–2',  'Swap bundle ID (3 places), create app icon, set up IAP products in App Store Connect'],
        ['Week 2–3',  'Wire real in_app_purchase (product IDs: split_fair_pdf_export, split_fair_configs). TestFlight internal build'],
        ['Week 3',    '5 App Store screenshots at 1290×2796px. Write privacy policy.'],
        ['Week 4',    'Submit for App Store review (~2–3 days turnaround)'],
        ['Week 4–5',  'Soft launch. Begin TikTok + Instagram content cadence'],
        ['Week 5+',   'Twitter/X thread campaign. Monitor reviews. Iterate on onboarding.'],
      ], ['Timeframe', 'Action']),

      spacer(200),

      // ── 10. PRE-SUBMISSION CHECKLIST ─────────────────────────────────────────
      h1('10  Pre-Submission Checklist'),
      rule(),
      body('Complete all of these before submitting to App Store / Google Play:'),
      spacer(80),

      ...[
        'Bundle ID swapped from com.yourname in 3 places (Android build.gradle, iOS xcodeproj, pubspec.yaml)',
        'App icon: 1024×1024 PNG, no alpha channel',
        'Privacy policy URL (required — use a free generator)',
        'IAP products created in App Store Connect: split_fair_pdf_export and split_fair_configs',
        '5 App Store screenshots at 1290×2796px for iPhone 15 Pro Max (required)',
        'App preview video — optional but boosts conversion ~30%',
        'Age rating questionnaire completed (this app = 4+)',
        'Support URL provided',
        'Test restore purchases flow on a real device',
        'TestFlight reviewed by at least 2 external testers',
      ].map(item => new Paragraph({
        numbering: { reference: 'check', level: 0 },
        ...sp(60, 60),
        indent: { left: 440, hanging: 220 },
        children: [new TextRun({ text: item, font: 'Arial', size: 22, color: BLACK })]
      })),

      spacer(200),

      // footer note
      rule(GRAY_MED),
      new Paragraph({
        alignment: AlignmentType.CENTER,
        ...sp(80, 0),
        children: [new TextRun({ text: 'Split Fair  •  Confidential Marketing Document  •  March 2026', font: 'Arial', size: 18, color: GRAY_TEXT })]
      })
    ]
  }]
});

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync('C:\\Users\\Nico Clairmont\\Projects\\rent_split\\Split_Fair_Marketing_Strategy.docx', buf);
  console.log('Done: Split_Fair_Marketing_Strategy.docx');
});
