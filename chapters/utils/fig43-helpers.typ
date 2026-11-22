#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

// ---------------------------------------------------------------------------
// 1. Palette ad alto contrasto (colorblind-safe) e stili di tratto
// ---------------------------------------------------------------------------
#let col-px      = rgb("#00897B") // Verde acqua: densità di ingresso p(x)
#let col-func    = rgb("#005AB5") // Blu vivido: funzione non lineare g(x)
#let col-py      = rgb("#D95F02") // Arancione caldo: densità trasformata p(y)
#let col-samples = rgb("#C62828") // Rosso cremisi: campioni (particelle)

#let st-px       = (paint: col-px, thickness: 1.5pt)
#let st-func     = (paint: col-func, thickness: 1.6pt)
#let st-py       = (paint: col-py, thickness: 1.5pt)
#let st-samples  = (paint: col-samples, thickness: 0.75pt)

// ---------------------------------------------------------------------------
// 2. Funzioni matematiche, generazione campioni e trasformazione
// ---------------------------------------------------------------------------
#let gaussian(x, mu, sigma) = {
  1.0 / (calc.sqrt(2.0 * calc.pi) * sigma) * calc.exp(-0.5 * calc.pow((x - mu) / sigma, 2))
}

// Funzione non lineare g(x)
#let g-nonlinear(x) = {
  let base = 0.67 - 0.14 * x
  let bump = 0.17 * calc.exp(-calc.pow((x - 0.21) / 0.115, 2))
  let step = -0.26 / (1.0 + calc.exp(-(x - 0.565) / 0.028))
  base + bump + step
}

// Funzione quantile (inversa della CDF normale standard, approssimazione di Acklam)
// per generare campioni deterministici stratificati + jitter riproducibili
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

// Genera N campioni da N(mu-x, sig-x^2), li trasforma tramite g(x) e calcola p(y)
#let compute-particle-transform(
  fn,
  mu-x,
  sig-x,
  n-samples: 140,
  n-y: 160,
  bw: 0.014,
) = {
  // Campioni stratificati con leggero jitter deterministico (LCG)
  let samples-x = range(n-samples).map(i => {
    let u-jitter = calc.rem(i * 37 + 17, 100) / 100.0
    let p = (i + 0.15 + 0.7 * u-jitter) / n-samples
    let p-clamped = calc.clamp(p, 0.001, 0.999)
    calc.clamp(mu-x + sig-x * norm-ppf(p-clamped), 0.01, 0.99)
  })

  // Trasformazione dei campioni attraverso g(x)
  let samples-y = samples-x.map(x => fn(x))

  // Densità continua reale p(y)
  let n-fine = 220
  let dx-fine = 1.0 / (n-fine - 1)
  let xs-fine = range(n-fine).map(i => i * dx-fine)
  let ys-fine = xs-fine.map(x => fn(x))
  let w-fine = xs-fine.map(x => gaussian(x, mu-x, sig-x) * dx-fine)

  let dy = 1.0 / (n-y - 1)
  let y-grid = range(n-y).map(j => j * dy)
  let py = y-grid.map(y => {
    range(n-fine).fold(0.0, (acc, i) => acc + w-fine.at(i) * gaussian(y, ys-fine.at(i), bw))
  })

  let max-py = calc.max(..py)

  (
    samples-x: samples-x,
    samples-y: samples-y,
    y-grid: y-grid,
    py: py,
    max-py: max-py,
  )
}

// ---------------------------------------------------------------------------
// 3. Componenti grafici (legende e sottografici)
// ---------------------------------------------------------------------------
#let legend-box(items) = {
  box(
    fill: white.transparentize(6%),
    stroke: 0.6pt + luma(60),
    inset: (x: 5pt, y: 3.5pt),
    {
      set text(size: 7pt)
      grid(
        columns: (14pt, auto),
        column-gutter: 5pt,
        row-gutter: 3pt,
        align: (center + horizon, left + horizon),
        ..items.flatten()
      )
    },
  )
}

#let swatch-fill(col) = rect(width: 12pt, height: 6pt, fill: col.transparentize(72%), stroke: 0.9pt + col)
#let swatch-line(st) = box(width: 12pt, height: 6pt, line(start: (0pt, 3pt), end: (12pt, 3pt), stroke: st))

// Grafico in alto a sinistra: densità continua p(y) + trattini orizzontali dei campioni Y
#let plot-py-particles(res) = {
  let x-max = res.max-py * 1.38
  let tick-len = x-max * 0.115
  let y-grid = res.y-grid
  let py-pairs = range(y-grid.len()).map(i => (res.py.at(i), y-grid.at(i)))
  let py-poly = ((0.0, 0.0),) + py-pairs + ((0.0, 1.0),)

  box(width: 4.5cm, height: 4.3cm)[
    #cetz.canvas({
      plot.plot(
        size: (3.55, 3.55),
        axis-style: "left",
        x-min: 0,
        x-max: x-max,
        y-min: 0,
        y-max: 1,
        x-ticks: (x-max * 0.25, x-max * 0.5, x-max * 0.75, x-max),
        y-ticks: (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7.5pt)[$p(y)$],
        y-label: text(size: 7.5pt)[$y$],
        {
          // Area continua p(y)
          plot.annotate({
            cetz.draw.line(
              ..py-poly,
              close: true,
              fill: col-py.transparentize(75%),
              stroke: none,
            )
          })
          plot.add(py-pairs, style: (stroke: st-py))

          // Trattini dei campioni trasformati lungo l'asse y
          plot.annotate({
            for sy in res.samples-y {
              cetz.draw.line((0.0, sy), (tick-len, sy), stroke: st-samples)
            }
          })
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-fill(col-py), [$p(y)$]),
        (swatch-line(st-samples), [Samples]),
      )),
    )
  ]
}

// Grafico in alto a destra: trasformazione non lineare y = g(x)
#let plot-gx-particles(fn) = {
  box(width: 5.6cm, height: 4.3cm)[
    #cetz.canvas({
      plot.plot(
        size: (4.55, 3.55),
        axis-style: "left",
        x-min: 0,
        x-max: 1,
        y-min: 0,
        y-max: 1,
        x-ticks: (0.2, 0.4, 0.6, 0.8, 1.0),
        y-ticks: (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7.5pt)[$x$],
        y-label: box(rotate(-90deg, reflow: true, text(size: 7.5pt)[$y = g(x)$])),
        {
          plot.add(domain: (0, 1), samples: 150, style: (stroke: st-func), fn)
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-line(st-func), [Function $g(x)$]),
      )),
    )
  ]
}

// Grafico in basso a destra: densità continua p(x) + trattini verticali dei campioni X
#let plot-px-particles(mu-x, sig-x, samples-x) = {
  let peak = gaussian(mu-x, mu-x, sig-x)
  let y-max = peak * 1.48
  let tick-h = y-max * 0.19

  box(width: 5.6cm, height: 2.55cm)[
    #cetz.canvas({
      plot.plot(
        size: (4.55, 1.85),
        axis-style: "left",
        x-min: 0,
        x-max: 1,
        y-min: 0,
        y-max: y-max,
        x-ticks: (0.2, 0.4, 0.6, 0.8, 1.0),
        y-ticks: (y-max * 0.2, y-max * 0.4, y-max * 0.6, y-max * 0.8, y-max),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7.5pt)[$x$],
        y-label: box(rotate(-90deg, reflow: true, text(size: 7.5pt)[$p(x)$])),
        {
          // Area continua p(x)
          plot.add(
            domain: (0, 1),
            samples: 180,
            fill: true,
            style: (stroke: st-px, fill: col-px.transparentize(75%)),
            x => gaussian(x, mu-x, sig-x),
          )

          // Trattini dei campioni estratti lungo l'asse x
          plot.annotate({
            for sx in samples-x {
              cetz.draw.line((sx, 0.0), (sx, tick-h), stroke: st-samples)
            }
          })
        },
      )
    })
    #place(
      top + right,
      dx: -4pt,
      dy: 3pt,
      legend-box((
        (swatch-fill(col-px), [$p(x)$]),
        (swatch-line(st-samples), [Samples]),
      )),
    )
  ]
}

// ---------------------------------------------------------------------------
// 4. Funzione principale esportata
// ---------------------------------------------------------------------------
#let fig-particle-representation(
  mu-x: 0.5,
  sig-x: 0.115,
  n-samples: 140,
  caption: auto,
) = {
  let res = compute-particle-transform(
    g-nonlinear,
    mu-x,
    sig-x,
    n-samples: n-samples,
  )

  let fig-caption = if caption == auto [
    The "particle" representation used by particle filters. The lower right graph shows samples (crimson ticks) drawn from a Gaussian random variable, $X$ (teal). These samples are passed through the nonlinear function shown in the upper right graph (blue). The resulting samples (crimson ticks) are distributed according to the random variable $Y$ (orange).
  ] else {
    caption
  }

  figure(
    box(
      stroke: 0.7pt + luma(40),
      inset: (x: 8pt, y: 7pt),
      grid(
        columns: (auto, auto),
        column-gutter: 10pt,
        row-gutter: 6pt,
        plot-py-particles(res),
        plot-gx-particles(g-nonlinear),
        [],
        plot-px-particles(mu-x, sig-x, res.samples-x),
      ),
    ),
    caption: fig-caption,
  )
}