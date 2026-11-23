#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

// ---------------------------------------------------------------------------
// 1. Palette ad alto contrasto (colorblind-safe) e stili di tratto
// ---------------------------------------------------------------------------
#let col-py      = rgb("#D95F02") // Arancione caldo: densità reale p(y)
#let col-kde     = rgb("#00897B") // Verde acqua: Kernel Density Estimate (KDE)
#let col-samples = rgb("#C62828") // Rosso cremisi: trattini dei campioni

#let st-py       = (paint: col-py, thickness: 1.4pt)
#let st-kde      = (paint: col-kde, thickness: 1.5pt)
#let st-samples  = (paint: col-samples, thickness: 0.7pt)

// ---------------------------------------------------------------------------
// 2. Funzioni matematiche, generazione campioni pseudo-casuali e KDE
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

// Calcola la densità reale di riferimento p(y)
#let compute-true-py(fn, mu-x, sig-x, n-y: 160, true-bw: 0.014) = {
  let n-fine = 220
  let dx-fine = 1.0 / (n-fine - 1)
  let xs-fine = range(n-fine).map(i => i * dx-fine)
  let ys-fine = xs-fine.map(x => fn(x))
  let w-fine = xs-fine.map(x => gaussian(x, mu-x, sig-x) * dx-fine)

  let dy = 1.0 / (n-y - 1)
  let y-grid = range(n-y).map(j => j * dy)
  let py = y-grid.map(y => {
    range(n-fine).fold(0.0, (acc, i) => acc + w-fine.at(i) * gaussian(y, ys-fine.at(i), true-bw))
  })

  (y-grid: y-grid, py: py)
}

// Esegue un singolo esperimento di campionamento casuale (LCG deterministico) + KDE
#let run-sampling-trial(fn, mu-x, sig-x, n-samples, y-grid, seed, kde-bw: 0.028) = {
  let m = 2147483647
  let a = 1103515245
  let c = 12345
  let state = calc.rem(seed * 7919 + 104729, m)

  let samples-y = ()
  for _ in range(n-samples) {
    state = calc.rem(a * state + c, m)
    let u = calc.clamp((state + 0.5) / m, 0.001, 0.999)
    let x = calc.clamp(mu-x + sig-x * norm-ppf(u), 0.01, 0.99)
    samples-y.push(fn(x))
  }

  let kde = y-grid.map(y => {
    samples-y.fold(0.0, (acc, sy) => acc + gaussian(y, sy, kde-bw)) / n-samples
  })

  (samples-y: samples-y, kde: kde)
}

// ---------------------------------------------------------------------------
// 3. Legenda e singolo riquadro sperimentale
// ---------------------------------------------------------------------------
#let legend-box(items) = {
  box(
    fill: white.transparentize(6%),
    stroke: 0.6pt + luma(60),
    inset: (x: 4.5pt, y: 2.8pt),
    {
      set text(size: 6.3pt)
      grid(
        columns: (13pt, auto),
        column-gutter: 4.5pt,
        row-gutter: 2pt,
        align: (center + horizon, left + horizon),
        ..items.flatten()
      )
    },
  )
}

#let swatch-fill(col) = rect(width: 11pt, height: 5pt, fill: col.transparentize(72%), stroke: 0.85pt + col)
#let swatch-line(st) = box(width: 11pt, height: 5pt, line(start: (0pt, 2.5pt), end: (11pt, 2.5pt), stroke: st))

// Singolo grafico verticale (p(y), campioni e stima KDE)
#let trial-plot(true-res, trial, x-max) = {
  let y-grid = true-res.y-grid
  let py-pairs = range(y-grid.len()).map(i => (true-res.py.at(i), y-grid.at(i)))
  let py-poly = ((0.0, 0.0),) + py-pairs + ((0.0, 1.0),)

  let kde-pairs = range(y-grid.len()).map(i => (trial.kde.at(i), y-grid.at(i)))
  let kde-poly = ((0.0, 0.0),) + kde-pairs + ((0.0, 1.0),)
  let tick-len = x-max * 0.115

  box(width: 4.35cm, height: 4.65cm)[
    #cetz.canvas({
      plot.plot(
        size: (3.55, 4.05),
        axis-style: "left",
        x-min: 0,
        x-max: x-max,
        y-min: 0,
        y-max: 1,
        x-ticks: (x-max * 0.3, x-max * 0.6, x-max * 0.9),
        y-ticks: (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7pt)[$p(y)$],
        y-label: text(size: 7pt)[$y$],
        {
          // Densità reale p(y)
          plot.annotate({
            cetz.draw.line(
              ..py-poly,
              close: true,
              fill: col-py.transparentize(76%),
              stroke: none,
            )
          })
          plot.add(py-pairs, style: (stroke: st-py))

          // Kernel Density Estimate (KDE)
          plot.annotate({
            cetz.draw.line(
              ..kde-poly,
              close: true,
              fill: col-kde.transparentize(82%),
              stroke: none,
            )
          })
          plot.add(kde-pairs, style: (stroke: st-kde))

          // Trattini orizzontali dei campioni lungo l'asse y
          plot.annotate({
            for sy in trial.samples-y {
              cetz.draw.line((0.0, sy), (tick-len, sy), stroke: st-samples)
            }
          })
        },
      )
    })
    #place(
      top + right,
      dx: -3pt,
      dy: 3pt,
      legend-box((
        (swatch-fill(col-py), [$p(y)$]),
        (swatch-line(st-samples), [Samples]),
        (swatch-fill(col-kde), [Kernel density]),
      )),
    )
  ]
}

// ---------------------------------------------------------------------------
// 4. Funzione principale esportata
// ---------------------------------------------------------------------------
#let fig-sampling-variance(
  mu-x: 0.5,
  sig-x: 0.115,
  n-low: 25,
  n-high: 250,
  seeds-low: (11, 27, 43),
  seeds-high: (19, 53, 89),
  caption: auto,
) = {
  let true-res = compute-true-py(g-nonlinear, mu-x, sig-x)

  let trials-low = seeds-low.map(s => run-sampling-trial(g-nonlinear, mu-x, sig-x, n-low, true-res.y-grid, s, kde-bw: 0.032))
  let trials-high = seeds-high.map(s => run-sampling-trial(g-nonlinear, mu-x, sig-x, n-high, true-res.y-grid, s, kde-bw: 0.024))

  // Scala orizzontale condivisa su tutti i 6 grafici
  let all-max = calc.max(
    ..true-res.py,
    ..trials-low.map(t => calc.max(..t.kde)),
    ..trials-high.map(t => calc.max(..t.kde)),
  )
  let x-max = all-max * 1.38

  let fig-caption = if caption == auto [
    Variance due to random sampling. Samples (crimson ticks) are drawn from a Gaussian and passed through a nonlinear function. Samples and kernel estimates (teal) resulting from repeated sampling of 25 (left column) and 250 (right column) samples are shown, compared against the true density $p(y)$ (orange). Each row shows one random experiment.
  ] else {
    caption
  }

  figure(
    grid(
      columns: (auto, auto, auto, auto),
      column-gutter: (5pt, 16pt, 5pt),
      row-gutter: 10pt,
      align: (top, top, top, top),
      // Intestazioni colonna + Riga 1
      text(size: 9pt)[*#[(a)]* #n-low samples],
      trial-plot(true-res, trials-low.at(0), x-max),
      text(size: 9pt)[*#[(b)]* #n-high samples],
      trial-plot(true-res, trials-high.at(0), x-max),

      // Riga 2
      [],
      trial-plot(true-res, trials-low.at(1), x-max),
      [],
      trial-plot(true-res, trials-high.at(1), x-max),

      // Riga 3
      [],
      trial-plot(true-res, trials-low.at(2), x-max),
      [],
      trial-plot(true-res, trials-high.at(2), x-max),
    ),
    caption: fig-caption,
  )
}