// ============================================================
// template.typ — page geometry, cover page, table of contents,
// and heading styling shared by the math and CS books.
// ============================================================

#import "theme.typ": theme, radii, font-heading, font-body, font-sans, font-mono

// ---------- cover page ----------
#let cover-page(title, subtitle, author, subject) = {
  set page(margin: 0pt, header: none, footer: none, numbering: none)
  box(width: 100%, height: 100%, fill: theme.primary)[
    // decorative accent shapes
    #place(top + right, dx: 2.2cm, dy: -3.4cm, circle(radius: 5.6cm, fill: theme.primary-soft))
    #place(top + right, dx: 0.2cm, dy: -1cm, circle(radius: 2.6cm, fill: theme.accent))
    #place(bottom + left, dx: -2.4cm, dy: 2.4cm, circle(radius: 4.2cm, fill: theme.teal))

    #place(top + left, dx: 2.2cm, dy: 2.4cm)[
      #text(font: font-sans, size: 11pt, fill: theme.gold, weight: "bold", tracking: 3pt)[
        #upper(subject)
      ]
    ]

    #place(left + horizon, dx: 2.2cm, dy: -1cm)[
      #box(width: 82%)[
        #text(font: font-heading, size: 40pt, fill: white, weight: "bold")[#title]
        #if subtitle != none [
          #v(10pt)
          #text(font: font-body, size: 15pt, fill: theme.gold, style: "italic")[#subtitle]
        ]
      ]
    ]

    #place(bottom + left, dx: 2.2cm, dy: -2.2cm)[
      #line(length: 3.4cm, stroke: 2pt + theme.accent)
      #v(6pt)
      #if author != none {
        text(font: font-sans, size: 12pt, fill: white, weight: "bold")[#author]
      }
    ]
  ]
}

// ---------- table of contents ----------
#let toc-page(title-color: theme.primary) = {
  show outline.entry.where(level: 1): it => context {
    v(14pt, weak: true)
    text(weight: "bold", size: 12pt, fill: theme.primary)[
      #link(it.element.location(), it.element.body)
      #box(width: 1fr, h(1fr) + repeat[#text(fill: theme.line)[.]])
      #link(it.element.location(), it.page())
    ]
  }
  show outline.entry.where(level: 2): it => context {
    text(size: 10pt, fill: theme.ink)[
      #h(1.1em) #link(it.element.location(), it.element.body)
      #box(width: 1fr, h(1fr) + repeat[#text(fill: theme.line)[.]])
      #link(it.element.location(), it.page())
    ]
  }
  heading(numbering: none, outlined: false)[#text(fill: title-color)[Table of Contents]]
  v(0.4cm)
  outline(title: none, depth: 2, indent: auto)
}

// ---------- the book() template ----------
#let book(
  title: "Untitled",
  subtitle: none,
  author: none,
  subject: "Mathematics",
  paper: "us-letter",
  body,
) = {
  set document(title: title, author: if author == none { () } else { (author,) })

  set text(font: font-body, size: 10.6pt, fill: theme.ink, lang: "en")
  set par(justify: true, leading: 0.62em, first-line-indent: 0em)
  set heading(numbering: "1.1")

  show raw: set text(font: font-mono, size: 9pt)
  show link: set text(fill: theme.teal)

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(0.4cm)
    block(above: 0pt, below: 22pt)[
      #text(font: font-sans, size: 12pt, fill: theme.accent, weight: "bold", tracking: 2.5pt)[
        #upper("Chapter") #counter(heading).display()
      ]
      #v(4pt)
      #text(font: font-heading, size: 26pt, fill: theme.primary, weight: "bold")[#it.body]
      #v(6pt)
      #line(length: 100%, stroke: 1.6pt + theme.accent)
    ]
  }

  show heading.where(level: 2): it => {
    v(16pt, weak: true)
    block(above: 0pt, below: 10pt)[
      #box(width: 8pt, height: 8pt, fill: theme.teal, radius: 2pt)
      #h(6pt)
      #text(font: font-sans, size: 15pt, fill: theme.primary-soft, weight: "bold")[
        #counter(heading).display() #it.body
      ]
    ]
  }

  show heading.where(level: 3): it => {
    v(12pt, weak: true)
    text(font: font-sans, size: 11.5pt, fill: theme.teal, weight: "bold")[#it.body]
    v(4pt, weak: true)
  }

  // ---------- front matter ----------
  cover-page(title, subtitle, author, subject)

  set page(
    paper: paper,
    margin: (top: 2.4cm, bottom: 2.6cm, x: 2.1cm),
    numbering: "i",
    header: none,
    footer: context {
      align(center)[
        #text(size: 8.5pt, fill: theme.muted)[#counter(page).display("i")]
      ]
    },
  )
  counter(page).update(1)
  toc-page()

  // ---------- body matter ----------
  set page(
    numbering: "1",
    header: context {
      let chapters = query(heading.where(level: 1).before(here()))
      let chapter-name = if chapters.len() > 0 { chapters.last().body } else { [] }
      grid(
        columns: (1fr, 1fr),
        align(left, text(size: 8pt, fill: theme.muted, tracking: 1pt)[#smallcaps[#title]]),
        align(right, text(size: 8pt, fill: theme.muted)[#chapter-name]),
      )
      v(-4pt)
      line(length: 100%, stroke: 0.4pt + theme.line)
    },
    footer: context {
      align(center)[
        #box(width: 20pt, height: 20pt, radius: 999pt, fill: theme.primary)[
          #align(center + horizon, text(fill: white, size: 8.5pt, weight: "bold")[#counter(page).display()])
        ]
      ]
    },
  )
  counter(page).update(1)
  counter(heading).update(0)

  body
}
