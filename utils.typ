// ============================================================
// utils.typ — reusable building blocks for the book body:
//   - callout(), definition(), theorem(), example(), note()
//   - code()                    styled source-code panel
//   - styled-table()            themed table with optional caption
//   - continuous-graph()        function plots (calculus, algebra)
//   - discrete-graph()          node/edge graphs (graph theory, automata)
//   - tree-diagram(), tnode()   tree drawings (BSTs, parse trees, recursion)
//
// All drawing utilities are pure Typst — no external packages — so the
// template compiles offline and won't break on a package-registry update.
// ============================================================

#import "theme.typ": theme, radii, font-mono, font-sans

// ---------- small numeric helpers ----------
#let map-range(v, in-min, in-max, out-min, out-max) = {
  if in-max == in-min { return out-min }
  out-min + (v - in-min) / (in-max - in-min) * (out-max - out-min)
}

#let linspace(a, b, n) = {
  if n <= 1 { return (a,) }
  range(n).map(i => a + (b - a) * i / (n - 1))
}

#let clamp(v, lo, hi) = calc.min(calc.max(v, lo), hi)

// ============================================================
// Callout boxes — definition / theorem / example / note
// ============================================================
#let kind-meta = (
  definition: (label: "Definition", color: theme.definition, soft: theme.teal-soft),
  theorem: (label: "Theorem", color: theme.theorem, soft: theme.panel),
  example: (label: "Example", color: theme.example, soft: theme.gold-soft),
  note: (label: "Note", color: theme.note, soft: theme.accent-soft),
)

#let callout(kind: "note", title: none, numbering: none, body) = {
  let meta = kind-meta.at(kind)
  block(
    width: 100%,
    fill: meta.soft,
    stroke: (left: 3pt + meta.color),
    inset: (left: 12pt, right: 12pt, top: 9pt, bottom: 10pt),
    radius: (top-right: radii.md, bottom-right: radii.md),
    breakable: true,
    above: 12pt,
    below: 12pt,
  )[
    #text(fill: meta.color, weight: "bold", size: 10pt, tracking: 0.7pt, font: font-sans)[
      #upper(meta.label)
      #if numbering != none [ #numbering]
      #if title != none [ #sym.dot.c #emph(title)]
    ]
    #v(3pt)
    #body
  ]
}

#let definition(title: none, numbering: none, body) = callout(kind: "definition", title: title, numbering: numbering, body)
#let theorem(title: none, numbering: none, body) = callout(kind: "theorem", title: title, numbering: numbering, body)
#let example(title: none, numbering: none, body) = callout(kind: "example", title: title, numbering: numbering, body)
#let note(title: none, body) = callout(kind: "note", title: title, body)

// ============================================================
// Code panel — for the CS book. Wraps a ```lang raw block.
// ============================================================
#let code(filename: none, body) = {
  block(
    width: 100%,
    fill: theme.panel,
    radius: radii.md,
    inset: 0pt,
    breakable: true,
    stroke: 0.6pt + theme.line,
    above: 12pt,
    below: 12pt,
  )[
    #if filename != none {
      block(
        width: 100%,
        fill: theme.primary,
        inset: (x: 10pt, y: 6pt),
        radius: (top-left: radii.md, top-right: radii.md),
      )[#text(fill: white, font: font-mono, size: 8.5pt)[#filename]]
    }
    #block(width: 100%, inset: 11pt, text(size: 9.2pt)[#body])
  ]
}

// ============================================================
// styled-table — themed wrapper around Typst's native table
// ============================================================
#let styled-table(headers: (), rows: (), caption: none, align: horizon, col-align: center) = {
  let n = headers.len()
  let content = table(
    columns: (1fr,) * n,
    stroke: none,
    align: col-align,
    inset: (x: 8pt, y: 6pt),
    fill: (col, row) => {
      if row == 0 { theme.primary } else if calc.rem(row, 2) == 0 { theme.panel } else { white }
    },
    table.header(
      ..headers.map(h => text(fill: white, weight: "bold", size: 9.5pt, font: font-sans)[#h])
    ),
    ..rows.flatten().map(c => text(size: 9.5pt)[#c])
  )
  let framed = block(
    width: 100%,
    stroke: 0.6pt + theme.line,
    radius: radii.sm,
    clip: true,
    content,
  )
  if caption == none { framed } else {
    figure(framed, caption: caption, kind: "table", supplement: [Table])
  }
}

// ============================================================
// continuous-graph — plot y = f(x) on a framed, gridded axis
// ============================================================
#let continuous-graph(
  f,
  x-min: -5, x-max: 5,
  y-min: auto, y-max: auto,
  width: 9cm, height: 5.5cm,
  samples: 140,
  color: theme.primary,
  x-label: none, y-label: none,
  title: none,
  x-step: auto, y-step: auto,
  caption: none,
) = {
  let xs = linspace(x-min, x-max, samples)
  let raw-ys = xs.map(x => {
    let y = f(x)
    if type(y) == float or type(y) == int { y } else { 0 }
  })

  let y-lo-raw = if y-min == auto { calc.min(..raw-ys) } else { y-min }
  let y-hi-raw = if y-max == auto { calc.max(..raw-ys) } else { y-max }
  let pad = (y-hi-raw - y-lo-raw) * 0.08
  if pad == 0 { pad = 1 }
  // only pad the bounds the caller left on auto — an explicit y-min/y-max
  // is respected exactly (e.g. y-min: 0 for a quantity that can't be negative)
  let y-lo = if y-min == auto { y-lo-raw - pad } else { y-lo-raw }
  let y-hi = if y-max == auto { y-hi-raw + pad } else { y-hi-raw }
  if y-min == auto and y-lo-raw >= 0 and y-lo < 0 { y-lo = 0 }

  let xstep = if x-step == auto { (x-max - x-min) / 6 } else { x-step }
  let ystep = if y-step == auto { (y-hi - y-lo) / 5 } else { y-step }

  let margin-left = 1.9cm
  let margin-bottom = 1.3cm
  let margin-top = if title != none { 0.9cm } else { 0.3cm }
  let margin-right = 0.35cm

  let to-px(x) = map-range(x, x-min, x-max, 0pt, width)
  let to-py(y) = map-range(y, y-lo, y-hi, height, 0pt)

  let n-x-ticks = int(calc.round((x-max - x-min) / xstep)) + 1
  let n-y-ticks = int(calc.round((y-hi - y-lo) / ystep)) + 1

  let plot-area = box(width: width, height: height)[
    #place(top + left, dx: 0pt, dy: 0pt,
      rect(width: width, height: height, fill: theme.panel, stroke: none))

    // gridlines
    #for i in range(n-x-ticks) {
      let xv = x-min + i * xstep
      let px = to-px(xv)
      place(top + left, dx: px, dy: 0pt, line(start: (0pt, 0pt), end: (0pt, height), stroke: 0.4pt + theme.line))
      place(top + left, dx: px - 8pt, dy: height + 3pt, box(width: 16pt, align(center, text(size: 6.8pt, fill: theme.muted)[#calc.round(xv, digits: 2)])))
    }
    #for i in range(n-y-ticks) {
      let yv = y-lo + i * ystep
      let py = to-py(yv)
      place(top + left, dx: 0pt, dy: py, line(start: (0pt, 0pt), end: (width, 0pt), stroke: 0.4pt + theme.line))
      place(top + left, dx: -30pt, dy: py - 4pt, box(width: 26pt, align(right, text(size: 6.8pt, fill: theme.muted)[#calc.round(yv, digits: 2)])))
    }

    // axes (x=0 / y=0) if within range, drawn heavier
    #if x-min <= 0 and 0 <= x-max {
      place(top + left, dx: to-px(0), dy: 0pt, line(start: (0pt, 0pt), end: (0pt, height), stroke: 0.8pt + theme.muted))
    }
    #if y-lo <= 0 and 0 <= y-hi {
      place(top + left, dx: 0pt, dy: to-py(0), line(start: (0pt, 0pt), end: (width, 0pt), stroke: 0.8pt + theme.muted))
    }

    // the curve itself
    #{
      let pts = xs.zip(raw-ys).map(p => (to-px(p.at(0)), to-py(clamp(p.at(1), y-lo, y-hi))))
      let cmds = (curve.move(pts.at(0)),) + pts.slice(1).map(p => curve.line(p))
      place(top + left, dx: 0pt, dy: 0pt, curve(stroke: 1.3pt + color, ..cmds))
    }

    // frame
    #place(top + left, dx: 0pt, dy: 0pt, rect(width: width, height: height, fill: none, stroke: 0.7pt + theme.muted))
  ]

  let labelled = box(width: width + margin-left + margin-right, height: height + margin-top + margin-bottom)[
    #if title != none {
      place(top + left, dx: margin-left, dy: 0pt, text(size: 9.5pt, weight: "bold", fill: theme.primary)[#title])
    }
    #place(top + left, dx: margin-left, dy: margin-top, plot-area)
    #if x-label != none {
      place(top + left, dx: margin-left, dy: margin-top + height + margin-bottom - 10pt,
        box(width: width, align(center, text(size: 8pt, fill: theme.muted)[#x-label])))
    }
    #if y-label != none {
      place(top + left, dx: -4pt, dy: margin-top + height / 2 + 12pt,
        rotate(-90deg, origin: left + horizon, text(size: 8pt, fill: theme.muted)[#y-label]))
    }
  ]

  if caption == none { labelled } else {
    figure(labelled, caption: caption, kind: "image", supplement: [Figure])
  }
}

// ============================================================
// discrete-graph — node/edge diagrams (graph theory, automata, DAGs)
// vertices: array of (id: str, label: content, pos: (x,y) in [0,1]^2, optional)
// edges:    array of (from: id, to: id, directed: bool, label: content)
// layout:   "circle" (auto) or "manual" (uses each vertex's pos)
// ============================================================
#let discrete-graph(
  vertices: (),
  edges: (),
  width: 8cm, height: 6cm,
  radius: 0.42cm,
  layout: "circle",
  directed: true,
  node-fill: white,
  node-stroke: theme.teal,
  edge-color: theme.muted,
  label-color: theme.primary,
  caption: none,
) = {
  let n = vertices.len()
  let pos = (:)
  if layout == "circle" {
    let cx = width / 2
    let cy = height / 2
    let r = calc.min(width, height) / 2 - radius - 6pt
    for (i, v) in vertices.enumerate() {
      let angle = -90deg + 360deg * i / n
      pos.insert(v.id, (cx + r * calc.cos(angle), cy + r * calc.sin(angle)))
    }
  } else {
    for v in vertices {
      pos.insert(v.id, (v.pos.at(0) * width, v.pos.at(1) * height))
    }
  }

  let content = box(width: width, height: height)[
    // edges first, underneath the nodes
    #for e in edges {
      let p1 = pos.at(e.from)
      let p2 = pos.at(e.to)
      let dx = p2.at(0) - p1.at(0)
      let dy = p2.at(1) - p1.at(1)
      let dxn = dx / 1pt
      let dyn = dy / 1pt
      let lenn = calc.sqrt(dxn * dxn + dyn * dyn)
      let ux = if lenn == 0 { 0 } else { dxn / lenn }
      let uy = if lenn == 0 { 0 } else { dyn / lenn }
      let is-directed = e.at("directed", default: directed)
      let end-shrink = if is-directed { radius + 7pt } else { radius }
      let start = (p1.at(0) + ux * radius, p1.at(1) + uy * radius)
      let end = (p2.at(0) - ux * end-shrink, p2.at(1) - uy * end-shrink)
      place(top + left, dx: 0pt, dy: 0pt, line(start: start, end: end, stroke: 1pt + edge-color))
      if is-directed {
        let tip = (p2.at(0) - ux * radius, p2.at(1) - uy * radius)
        let back = (tip.at(0) - ux * 7pt, tip.at(1) - uy * 7pt)
        let px = -uy * 3.2pt
        let py = ux * 3.2pt
        let wing1 = (back.at(0) + px, back.at(1) + py)
        let wing2 = (back.at(0) - px, back.at(1) - py)
        place(top + left, dx: 0pt, dy: 0pt,
          curve(fill: edge-color, stroke: none,
            curve.move(tip), curve.line(wing1), curve.line(wing2), curve.close()))
      }
      if "label" in e {
        let mx = (start.at(0) + end.at(0)) / 2
        let my = (start.at(1) + end.at(1)) / 2
        place(top + left, dx: mx - 9pt, dy: my - 7pt,
          box(fill: white, inset: 1.5pt, radius: 2pt, text(size: 7pt, fill: edge-color)[#e.label]))
      }
    }
    // nodes on top
    #for v in vertices {
      let p = pos.at(v.id)
      place(top + left, dx: p.at(0) - radius, dy: p.at(1) - radius,
        circle(radius: radius, fill: node-fill, stroke: 1.4pt + node-stroke)[
          #align(center + horizon, text(size: 9pt, weight: "bold", fill: label-color)[#v.label])
        ])
    }
  ]

  if caption == none { content } else {
    figure(content, caption: caption, kind: "image", supplement: [Figure])
  }
}

// ============================================================
// tree-diagram — draws a rooted tree from a nested tnode() structure
// ============================================================
#let tnode(label, children: ()) = (label: label, children: children)

#let layout-tree(node, depth: 0, leaf-i: 0) = {
  if node.children.len() == 0 {
    let p = (x: leaf-i, label: node.label, depth: depth)
    (p, leaf-i + 1, (p,), ())
  } else {
    let all-positions = ()
    let all-edges = ()
    let cur-i = leaf-i
    let child-poses = ()
    for child in node.children {
      let (cpos, next-i, cpositions, cedges) = layout-tree(child, depth: depth + 1, leaf-i: cur-i)
      child-poses.push(cpos)
      all-positions = all-positions + cpositions
      all-edges = all-edges + cedges
      cur-i = next-i
    }
    let own-x = child-poses.map(p => p.x).sum() / child-poses.len()
    let p = (x: own-x, label: node.label, depth: depth)
    let new-edges = child-poses.map(cp => (parent: p, child: cp))
    (p, cur-i, all-positions + (p,), all-edges + new-edges)
  }
}

#let tree-diagram(
  data,
  width: 9cm, height: 5cm,
  radius: 0.38cm,
  node-shape: "circle",
  node-fill: white,
  node-stroke: theme.primary,
  edge-color: theme.muted,
  label-color: theme.primary,
  caption: none,
) = {
  let (root-pos, n-leaves, all-positions, all-edges) = layout-tree(data)
  let max-depth = all-positions.map(p => p.depth).fold(0, (a, b) => calc.max(a, b))

  let to-x(x) = if n-leaves <= 1 { width / 2 } else { map-range(x, 0, n-leaves - 1, radius + 4pt, width - radius - 4pt) }
  let to-y(d) = if max-depth == 0 { height / 2 } else { map-range(d, 0, max-depth, radius + 4pt, height - radius - 4pt) }

  let node-at(p) = {
    let cx = to-x(p.x)
    let cy = to-y(p.depth)
    if node-shape == "circle" {
      place(top + left, dx: cx - radius, dy: cy - radius,
        circle(radius: radius, fill: node-fill, stroke: 1.3pt + node-stroke)[
          #align(center + horizon, text(size: 8.5pt, weight: "bold", fill: label-color)[#p.label])
        ])
    } else {
      let w = radius * 2.4
      let h = radius * 1.8
      place(top + left, dx: cx - w / 2, dy: cy - h / 2,
        rect(width: w, height: h, fill: node-fill, stroke: 1.3pt + node-stroke, radius: radii.sm)[
          #align(center + horizon, text(size: 8.5pt, weight: "bold", fill: label-color)[#p.label])
        ])
    }
  }

  let content = box(width: width, height: height)[
    #for e in all-edges {
      let x1 = to-x(e.parent.x); let y1 = to-y(e.parent.depth)
      let x2 = to-x(e.child.x); let y2 = to-y(e.child.depth)
      place(top + left, dx: 0pt, dy: 0pt, line(start: (x1, y1), end: (x2, y2), stroke: 1pt + edge-color))
    }
    #for p in all-positions { node-at(p) }
  ]

  if caption == none { content } else {
    figure(content, caption: caption, kind: "image", supplement: [Figure])
  }
}
