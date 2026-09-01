// ============================================================
// theme.typ — colors, fonts and spacing tokens
// Shared by template.typ and utils.typ so both books (math & CS)
// look like they belong to the same series while staying lively
// rather than "textbook beige" or "cartoon childish".
// ============================================================

#let theme = (
  // --- brand colors ---
  primary: rgb("#16213E"), // deep ink navy — headings, rules, chapter numerals
  primary-soft: rgb("#2B3A67"), // lighter navy — subheadings, running header
  accent: rgb("#FF5D5D"), // punchy coral — the "fun" highlight color
  accent-soft: rgb("#FFE3E0"), // pale coral tint — fills, callout backgrounds
  teal: rgb("#0FA3A3"), // teal — second accent, used for CS/graph content
  teal-soft: rgb("#DCF5F3"),
  gold: rgb("#F4A300"), // warm gold — used sparingly (warnings/highlights)
  gold-soft: rgb("#FDEBC8"),

  // --- neutrals ---
  ink: rgb("#1B1B1F"), // body text
  muted: rgb("#5B5F6B"), // captions, page numbers, secondary text
  line: rgb("#D9DBE3"), // hairlines, table rules
  paper: rgb("#FFFFFF"), // page background
  panel: rgb("#F5F6FA"), // soft panel background (code blocks, tables)

  // --- semantic mapping (so content authors don't pick raw colors) ---
  definition: rgb("#0FA3A3"),
  theorem: rgb("#16213E"),
  example: rgb("#F4A300"),
  note: rgb("#FF5D5D"),
  code: rgb("#2B3A67"),
)

// Font stacks — first choice is a nice modern face, tail falls back to
// whatever ships with the reader's Typst install so the template never
// hard-fails on a missing font.
// Each stack ends in a family that ships with virtually every OS
// (Liberation/DejaVu on Linux, the named family on macOS/Windows) so the
// template degrades gracefully instead of erroring when a nicer font
// isn't installed.
#let font-heading = ("Archivo Black", "Archivo", "Arial Black", "Inter", "Helvetica Neue", "Liberation Sans", "Arial")
#let font-body = ("Source Serif 4", "Source Serif Pro", "Libertinus Serif", "New Computer Modern", "Georgia", "Liberation Serif", "Times New Roman")
#let font-sans = ("Inter", "Source Sans 3", "Source Sans Pro", "Helvetica Neue", "Liberation Sans", "Arial", "DejaVu Sans")
#let font-mono = ("JetBrains Mono", "Cascadia Code", "Consolas", "Menlo", "DejaVu Sans Mono", "Liberation Mono")

// Spacing scale (in em/pt) reused across template + utils
#let radii = (sm: 3pt, md: 6pt, lg: 10pt)
