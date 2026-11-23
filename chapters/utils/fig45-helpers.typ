#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

// ---------------------------------------------------------------------------
// 1. Palette ad alto contrasto (colorblind-safe) e stili di tratto
// ---------------------------------------------------------------------------
#let col-py       = rgb("#D95F02") // Arancione caldo: densità reale p(y)
#let col-samples  = rgb("#C62828") // Rosso cremisi: trattini campioni & media reale
#let col-py-gauss = rgb("#6A1B9A") // Viola scuro: gaussiana reale di p(y)
#let col-approx   = rgb("#D81B60") // Magenta: gaussiana e media dei campioni
#let col-hist     = rgb("#005AB5") // Blu vivido: istogramma dei campioni
#let col-kde      = rgb("#00897B") // Verde acqua: kernel density estimate (KDE)

#let st-py        = (paint: col-py, thickness: 1.4pt)
#let st-samples   = (paint: col-samples, thickness: 0.75pt)
#let st-py-gauss  = (paint: col-py-gauss, thickness: 1.5pt)
#let st-approx    = (paint: col-approx, thickness: 1.5pt, dash: "dashed")
#let st-mean      = (paint: col-samples, thickness: 1.25pt)
#let st-mean-apx  = (paint: col-approx, thickness: 1.25pt, dash: "dashed")
#let st-hist      = (paint: col-hist, thickness: 0.95pt)
#let st-kde       = (paint: col-kde, thickness: 1.5pt)

// ---------------------------------------------------------------------------
// 2. Funzioni matematiche, generazione particelle e ricostruzione densità
// ---------------------------------------------------------------------------
#let gaussian(x, mu, sigma) = {
  1.0 / (calc.sqrt(2.0 * calc.pi) * sigma) * calc.exp(-0.5 * calc.pow((x - mu) / sigma, 2))
}

// Funzione non lineare g(x) che genera la densità bimodale p(y)
#let g-nonlinear(x) = {
  let base = 0.67 - 0.14 * x
  let bump = 0.17 * calc.exp(-calc.pow((x - 0.21) / 0.115, 2))
  let step = -0.26 / (1.0 + calc.exp(-(x - 0.565) / 0.028))
  base + bump + step
}

// Funzione quantile normale standard (approssimazione di Acklam)
#let norm-ppf(p) = {
  let a1 = -3.969683028665376e+01
  let a2 =  2.209460984245205e+02
  let a3 = -2.759285104469687e+02
  let a4 =  1.383577518672690e+02
  let a5 = -3.066479806614716e+01
  let a6 =  2.506628277459239e+00

  let b1 = -5.447609879822406e+01
  let b2 =  1.615858368580409e+02
  let b3 = -1.556989798598866e+02
  let b4 =  6.680131188771972e+01
  let b5 = -1.328068155288572e+01

  let c1 = -7.784894002430293e-03
  let c2 = -3.223964580411365e-01
  let c3 = -2.400758277161838e+00
  let c4 = -2.549732539343734e+00
  let c5 =  4.374664141464968e+00
  let c6 =  2.938163982698783e+00

  let d1 =  7.784695709041462e-03
  let d2 =  3.224671290700398e-01
  let d3 =  2.445134137142996e+00
  let d4 =  3.754408661907416e+00

  let p-low = 0.02425
  let p-high = 1.0 - p-low

  if p < p-low {
    let q = calc.sqrt(-2.0 * calc.ln(p))
    (((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) /((((d1 * q + d2) * q + d3) * q + d4) * q + 1.0)
  } else if p <= p-high {
    let q = p - 0.5
    let r = q * q
    (((((a1 * r + a2) * r + a3) * r + a4) * r + a5) * r + a6) * q /(((((b1 * r + b2) * r + b3) * r + b4) * r + b5) * r + 1.0)
  } else {
    let q = calc.sqrt(-2.0 * calc.ln(1.0 - p))
    -(((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) /((((d1 * q + d2) * q + d3) * q + d4) * q + 1.0)
  }
}

// Calcola p(y) reale e le 4 rappresentazioni estratte dalle particelle:
// (a) campioni, (b) gaussiana dei campioni, (c) istogramma, (d) KDE
#let compute-density-extractions(
  fn,
  mu-x,
  sig-x,
  n-samples: 130,
  n-bins: 24,
  kde-bw: 0.032,
  n-y: 160,
  true-bw: 0.014,
) = {
  // 1. Densità reale p(y) e momenti veri
  let n-fine = 220
  let dx-fine = 1.0 / (n-fine - 1)
  let xs-fine = range(n-fine).map(i => i * dx-fine)
  let ys-fine = xs-fine.map(x => fn(x))
  let w-fine = xs-fine.map(x => gaussian(x, mu-x, sig-x) * dx-fine)

  let mean-y = range(n-fine).fold(0.0, (acc, i) => acc + ys-fine.at(i) * w-fine.at(i))
  let var-y = range(n-fine).fold(0.0, (acc, i) => acc + calc.pow(ys-fine.at(i) - mean-y, 2) * w-fine.at(i))
  let sig-y = calc.sqrt(var-y)

  let dy = 1.0 / (n-y - 1)
  let y-grid = range(n-y).map(j => j * dy)
  let py = y-grid.map(y => {
    range(n-fine).fold(0.0, (acc, i) => acc + w-fine.at(i) * gaussian(y, ys-fine.at(i), true-bw))
  })
  let py-gauss = y-grid.map(y => gaussian(y, mean-y, sig-y))

  // 2. Campioni (particelle) estratti e trasformati attraverso g(x)
  let samples-y = range(n-samples).map(i => {
    let jitter = calc.rem(i * 41 + 19, 100) / 100.0
    let p = calc.clamp((i + 0.15 + 0.7 * jitter) / n-samples, 0.001, 0.999)
    let x = calc.clamp(mu-x + sig-x * norm-ppf(p), 0.01, 0.99)
    fn(x)
  })

  // 3. Approssimazione gaussiana (b) dai campioni
  let samp-mean = samples-y.fold(0.0, (acc, y) => acc + y) / n-samples
  let samp-var = samples-y.fold(0.0, (acc, y) => acc + calc.pow(y - samp-mean, 2)) / (n-samples - 1)
  let samp-sig = calc.sqrt(samp-var)
  let samp-gauss = y-grid.map(y => gaussian(y, samp-mean, samp-sig))

  // 4. Approssimazione a istogramma (c) dai campioni
  let dy-bin = 1.0 / n-bins
  let counts = range(n-bins).map(_ => 0)
  for sy in samples-y {
    let idx = calc.clamp(int(calc.floor(sy / dy-bin)), 0, n-bins - 1)
    counts.at(idx) = counts.at(idx) + 1
  }
  let hist-bins = range(n-bins).map(j => (
    y0: j * dy-bin,
    y1: (j + 1) * dy-bin,
    height: counts.at(j) / (n-samples * dy-bin),
  ))

  // 5. Kernel Density Estimate (d) dai campioni
  let kde = y-grid.map(y => {
    samples-y.fold(0.0, (acc, sy) => acc + gaussian(y, sy, kde-bw)) / n-samples
  })

  let max-py = calc.max(..py, ..py-gauss, ..samp-gauss, ..hist-bins.map(b => b.height), ..kde)

  (
    y-grid: y-grid,
    py: py,
    py-gauss: py-gauss,
    mean-y: mean-y,
    samples-y: samples-y,
    samp-mean: samp-mean,
    samp-gauss: samp-gauss,
    hist-bins: hist-bins,
    kde: kde,
    max-py: max-py,
  )
}

// ---------------------------------------------------------------------------
// 3. Legende e costruttore del singolo pannello verticale
// ---------------------------------------------------------------------------
#let legend-box(items) = {
  box(
    fill: white.transparentize(6%),
    stroke: 0.6pt + luma(60),
    inset: (x: 4.5pt, y: 3pt),
    {
      set text(size: 6.5pt)
      grid(
        columns: (13pt, auto),
        column-gutter: 4.5pt,
        row-gutter: 2.5pt,
        align: (center + horizon, left + horizon),
        ..items.flatten()
      )
    },
  )
}

#let swatch-fill(col, stroke-col: auto) = {
  let sc = if stroke-col == auto { col } else { stroke-col }
  rect(width: 11pt, height: 5.5pt, fill: col.transparentize(72%), stroke: 0.85pt + sc)
}
#let swatch-line(st) = box(width: 11pt, height: 5.5pt, line(start: (0pt, 2.75pt), end: (11pt, 2.75pt), stroke: st))

// Riquadro completo di un pannello (a), (b), (c) o (d)
#let density-panel(label, res, legend-items, overlay-fn) = {
  let x-max = res.max-py * 1.38
  let y-grid = res.y-grid
  let py-pairs = range(y-grid.len()).map(i => (res.py.at(i), y-grid.at(i)))
  let py-poly = ((0.0, 0.0),) + py-pairs + ((0.0, 1.0),)

  grid(
    columns: (auto, auto),
    column-gutter: 5pt,
    align: (top, top),
    text(weight: "bold", size: 9.5pt)[#label],
    box(
      stroke: 0.7pt + luma(40),
      inset: (x: 7pt, y: 6pt),
      {
        box(width: 4.35cm, height: 5.65cm)[
          #cetz.canvas({
            plot.plot(
              size: (3.45, 4.95),
              axis-style: "left",
              x-min: 0,
              x-max: x-max,
              y-min: 0,
              y-max: 1,
              x-ticks: (x-max * 0.3, x-max * 0.6, x-max * 0.9),
              y-ticks: (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0),
              x-format: _ => [],
              y-format: _ => [],
              x-label: text(size: 7.5pt)[$p(y)$],
              y-label: text(size: 7.5pt)[$y$],
              {
                // Densità reale p(y) comune a tutti i pannelli
                plot.annotate({
                  cetz.draw.line(
                    ..py-poly,
                    close: true,
                    fill: col-py.transparentize(76%),
                    stroke: none,
                  )
                })
                plot.add(py-pairs, style: (stroke: st-py))

                // Sovrapposizione specifica del pannello
                overlay-fn(x-max)
              },
            )
          })
          #place(
            top + right,
            dx: -3pt,
            dy: 3pt,
            legend-box(legend-items),
          )
        ]
      },
    ),
  )
}

// ---------------------------------------------------------------------------
// 4. Funzione principale esportata
// ---------------------------------------------------------------------------
#let fig-particle-density-extraction(
  mu-x: 0.5,
  sig-x: 0.115,
  n-samples: 130,
  n-bins: 24,
  kde-bw: 0.032,
  caption: auto,
) = {
  let res = compute-density-extractions(
    g-nonlinear,
    mu-x,
    sig-x,
    n-samples: n-samples,
    n-bins: n-bins,
    kde-bw: kde-bw,
  )

  let y-grid = res.y-grid
  let g-pairs = range(y-grid.len()).map(i => (res.py-gauss.at(i), y-grid.at(i)))
  let sg-pairs = range(y-grid.len()).map(i => (res.samp-gauss.at(i), y-grid.at(i)))
  let kde-pairs = range(y-grid.len()).map(i => (res.kde.at(i), y-grid.at(i)))
  let kde-poly = ((0.0, 0.0),) + kde-pairs + ((0.0, 1.0),)

  let fig-caption = if caption == auto [
    Different ways of extracting densities from particles. *(a)* Density $p(y)$ (orange) and sample set approximation (crimson ticks), *(b)* Gaussian approximation (mean and variance: true Gaussian in solid purple, sample Gaussian in dashed magenta), *(c)* histogram approximation (blue), *(d)* kernel density estimate (teal). The choice of approximation strongly depends on the specific application and the computational resources.
  ] else {
    caption
  }

  figure(
    grid(
      columns: (auto, auto),
      column-gutter: 14pt,
      row-gutter: 12pt,
      // (a) Density and sample set approximation
      density-panel(
        "(a)",
        res,
        (
          (swatch-fill(col-py), [$p(y)$]),
          (swatch-line(st-samples), [Samples]),
        ),
        x-max => {
          let tick-len = x-max * 0.11
          plot.annotate({
            for sy in res.samples-y {
              cetz.draw.line((0.0, sy), (tick-len, sy), stroke: st-samples)
            }
          })
        },
      ),
      // (b) Gaussian approximation (mean and variance)
      density-panel(
        "(b)",
        res,
        (
          (swatch-fill(col-py), [$p(y)$]),
          (swatch-line(st-py-gauss), [Gaussian of $p(y)$]),
          (swatch-line(st-mean), [Mean of $p(y)$]),
          (swatch-line(st-approx), [Gaussian of samples]),
          (swatch-line(st-mean-apx), [Mean of samples]),
        ),
        x-max => {
          plot.add(g-pairs, style: (stroke: st-py-gauss))
          plot.add(sg-pairs, style: (stroke: st-approx))

          // Media reale di p(y)
          plot.add(((0.0, res.mean-y), (x-max * 0.92, res.mean-y)), style: (stroke: st-mean))
          plot.add(((0.0, res.mean-y),), mark: "x", mark-size: 0.15, mark-style: (stroke: st-mean))

          // Media dei campioni
          plot.add(((0.0, res.samp-mean), (x-max * 0.92, res.samp-mean)), style: (stroke: st-mean-apx))
          plot.add(((0.0, res.samp-mean),), mark: "o", mark-size: 0.14, mark-style: (stroke: (paint: col-approx, thickness: 1.1pt), fill: white))
        },
      ),
      // (c) Histogram approximation
      density-panel(
        "(c)",
        res,
        (
          (swatch-fill(col-py), [$p(y)$]),
          (swatch-fill(col-hist), [Histogram]),
        ),
        _ => {
          plot.annotate({
            for b in res.hist-bins {
              if b.height > 0.02 {
                cetz.draw.rect(
                  (0.0, b.y0),
                  (b.height, b.y1),
                  fill: col-hist.transparentize(82%),
                  stroke: st-hist,
                )
              }
            }
          })
        },
      ),
      // (d) Kernel density estimate
      density-panel(
        "(d)",
        res,
        (
          (swatch-fill(col-py), [$p(y)$]),
          (swatch-fill(col-kde), [Kernel density]),
        ),
        _ => {
          plot.annotate({
            cetz.draw.line(
              ..kde-poly,
              close: true,
              fill: col-kde.transparentize(78%),
              stroke: none,
            )
          })
          plot.add(kde-pairs, style: (stroke: st-kde))
        },
      ),
    ),
    caption: fig-caption,
  )
}