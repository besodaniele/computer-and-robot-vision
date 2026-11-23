#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

// ---------------------------------------------------------------------------
// 1. Palette ad alto contrasto (colorblind-safe) e stili di tratto
// ---------------------------------------------------------------------------
#let col-f         = rgb("#005AB5") // Blu vivido: densità target f
#let col-g         = rgb("#D95F02") // Arancione caldo: densità proposta g
#let col-samples-f = rgb("#00897B") // Verde acqua: campioni estratti da f
#let col-samples-g = rgb("#C62828") // Rosso cremisi: campioni da g e pesi f(x)/g(x)

#let st-f          = (paint: col-f, thickness: 1.6pt)
#let st-g          = (paint: col-g, thickness: 1.6pt)
#let st-tick-f     = (paint: col-samples-f, thickness: 0.85pt)
#let st-tick-g     = (paint: col-samples-g, thickness: 0.85pt)
#let st-zero       = (paint: luma(30), thickness: 0.9pt)

// ---------------------------------------------------------------------------
// 2. Densità f(x) e g(x) e generazione campioni deterministica
// ---------------------------------------------------------------------------
#let gaussian(x, mu, sigma) = {
  1.0 / (calc.sqrt(2.0 * calc.pi) * sigma) * calc.exp(-0.5 * calc.pow((x - mu) / sigma, 2))
}

// Densità target f(x) su [0, 12] (picco stretto in x = 2 + spalla larga in x = 4.2)
#let density-f(x) = {
  0.004 + 0.34 * gaussian(x, 2.0, 0.55) + 0.58 * gaussian(x, 4.15, 1.8)
}

// Densità proposta g(x) su [0, 12] (picco in x = 9 + base uniforme non nulla per rapporto f/g stabile)
#let density-g(x) = {
  0.025 + 0.72 * gaussian(x, 9.0, 1.03)
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

// Campioni stratificati da una densità arbitraria tramite inversione numerica della CDF
#let sample-from-density(fn, n-samples, x-min: 0.0, x-max: 12.0, n-grid: 400, seed: 17) = {
  let dx = (x-max - x-min) / n-grid
  let cdf = ()
  let acc = 0.0
  for i in range(n-grid) {
    let xm = x-min + (i + 0.5) * dx
    acc = acc + fn(xm) * dx
    cdf.push(acc)
  }
  let total = cdf.last()
  let cdf-norm = cdf.map(v => v / total)

  range(n-samples).map(k => {
    let jitter = calc.rem(k * 43 + seed, 100) / 100.0
    let target = (k + 0.15 + 0.7 * jitter) / n-samples
    let idx = 0
    while idx < n-grid - 1 and cdf-norm.at(idx) < target {
      idx = idx + 1
    }
    let prev = if idx == 0 { 0.0 } else { cdf-norm.at(idx - 1) }
    let curr = cdf-norm.at(idx)
    let frac = if curr > prev { (target - prev) / (curr - prev) } else { 0.5 }
    x-min + (idx + frac) * dx
  })
}

// ---------------------------------------------------------------------------
// 3. Costruttore del singolo pannello (a), (b) o (c)
// ---------------------------------------------------------------------------
#let is-panel(
  label,
  show-g: false,
  ticks: (),
  tick-style: st-tick-f,
) = {
  let y-base = -0.072
  let y-min = -0.095
  let y-max = 0.355

  grid(
    columns: (auto, auto),
    column-gutter: 6pt,
    align: (top, top),
    text(weight: "bold", size: 9.5pt)[#label],
    {
      set text(size: 7pt)
      cetz.canvas({
        plot.plot(
          size: (8.6, 3.35),
          x-min: 0,
          x-max: 12,
          y-min: y-min,
          y-max: y-max,
          x-ticks: (2, 4, 6, 8, 10, 12),
          y-ticks: (0, 0.1, 0.2, 0.3),
          x-label: none,
          y-label: none,
          {
            // Linea dello zero y = 0 che separa le curve dalla fascia dei campioni
            plot.add(((0.0, 0.0), (12.0, 0.0)), style: (stroke: st-zero))

            // Densità target f(x) ed etichetta "f"
            plot.add(domain: (0, 12), samples: 220, style: (stroke: st-f), density-f)
            plot.annotate({
              cetz.draw.content(
                (1.0, 0.195),
                text(fill: col-f, weight: "bold", size: 11pt)[$f$],
              )
            })

            // Densità proposta g(x) ed etichetta "g" (nei pannelli b e c)
            if show-g {
              plot.add(domain: (0, 12), samples: 220, style: (stroke: st-g), density-g)
              plot.annotate({
                cetz.draw.content(
                  (7.55, 0.195),
                  text(fill: col-g, weight: "bold", size: 11pt)[$g$],
                )
              })
            }

            // Trattini verticali dei campioni (con altezza fissa o pesata)
            plot.annotate({
              for t in ticks {
                cetz.draw.line(
                  (t.x, y-base),
                  (t.x, y-base + t.h),
                  stroke: tick-style,
                )
              }
            })
          },
        )
      })
    },
  )
}

// ---------------------------------------------------------------------------
// 4. Funzione principale esportata
// ---------------------------------------------------------------------------
#let fig-importance-sampling(
  n-samples: 95,
  caption: auto,
) = {
  // Campioni estratti direttamente da f per il pannello (a)
  let xs-f = sample-from-density(density-f, n-samples, seed: 13)
  let ticks-a = xs-f.map(x => (x: x, h: 0.015))

  // Campioni estratti da g per i pannelli (b) e (c)
  let xs-g = sample-from-density(density-g, n-samples, seed: 29)
  let ticks-b = xs-g.map(x => (x: x, h: 0.015))

  // Pesi d'importanza w(x) = f(x) / g(x) normalizzati per l'altezza in (c)
  let raw-w = xs-g.map(x => density-f(x) / density-g(x))
  let max-w = calc.max(..raw-w)
  let ticks-c = range(xs-g.len()).map(i => (
    x: xs-g.at(i),
    h: 0.003 + 0.044 * (raw-w.at(i) / max-w),
  ))

  let fig-caption = if caption == auto [
    Illustration of importance factors in particle filters: *(a)* We seek to approximate the target density $f$ (blue; ideal samples shown in teal). *(b)* Instead of sampling from $f$ directly, we can only generate samples from a different density, $g$ (orange). Samples drawn from $g$ are shown at the bottom of this diagram (crimson). *(c)* A sample of $f$ is obtained by attaching the weight $f(x)/g(x)$ to each sample $x$ (represented by the height of the crimson bars). In particle filters, $f$ corresponds to the belief $"bel"(x_t)$ and $g$ to the belief $overline("bel")(x_t)$.
  ] else {
    caption
  }

  figure(
    stack(
      dir: ttb,
      spacing: 10pt,
      is-panel("(a)", show-g: false, ticks: ticks-a, tick-style: st-tick-f),
      is-panel("(b)", show-g: true, ticks: ticks-b, tick-style: st-tick-g),
      is-panel("(c)", show-g: true, ticks: ticks-c, tick-style: st-tick-g),
    ),
    caption: fig-caption,
  )
}