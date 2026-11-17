#import "@preview/cetz:0.3.4"
#import "@preview/cetz-plot:0.1.1": plot

// ---------------------------------------------------------------------------
// 1. Palette ad alto contrasto (colorblind-safe) e stili di tratto
// ---------------------------------------------------------------------------
#let col-px       = rgb("#00897B") // Verde acqua: densità di ingresso p(x)
#let col-func     = rgb("#005AB5") // Blu vivido: funzione non lineare g(x)
#let col-approx   = rgb("#D81B60") // Magenta: approssimazione EKF / UKF e g(sigma points)
#let col-py       = rgb("#D95F02") // Arancione caldo: densità reale trasformata p(y)
#let col-py-gauss = rgb("#6A1B9A") // Viola scuro: gaussiana reale di p(y)
#let col-mean     = rgb("#C62828") // Rosso cremisi: media reale e sigma-points su x
#let col-proj     = rgb("#334155") // Ardesia: linee punteggiate di proiezione

#let st-px        = (paint: col-px, thickness: 1.4pt)
#let st-func      = (paint: col-func, thickness: 1.6pt)
#let st-py        = (paint: col-py, thickness: 1.3pt)
#let st-py-gauss  = (paint: col-py-gauss, thickness: 1.5pt)
#let st-approx    = (paint: col-approx, thickness: 1.5pt, dash: "dashed")
#let st-mean      = (paint: col-mean, thickness: 1.25pt)
#let st-mean-apx  = (paint: col-approx, thickness: 1.25pt, dash: "dashed")
#let st-proj      = (paint: col-proj, thickness: 0.95pt, dash: "dotted")

// ---------------------------------------------------------------------------
// 2. Funzioni matematiche, linearizzazione EKF e trasformata UKF
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

// Derivata prima g'(x) per la linearizzazione EKF in x = mu
#let g-nonlinear-deriv(x) = {
  let d-base = -0.14
  let u-bump = (x - 0.21) / 0.115
  let d-bump = 0.17 * calc.exp(-u-bump * u-bump) * (-2.0 * u-bump / 0.115)
  let s = 1.0 / (1.0 + calc.exp(-(x - 0.565) / 0.028))
  let d-step = -0.26 * s * (1.0 - s) / 0.028
  d-base + d-bump + d-step
}

// Calcola p(y) reale, gaussiana reale, gaussiana EKF e gaussiana UKF
#let transform-ekf-ukf(fn, dfn, mu-x, sig-x, lambda: 1.2, n-x: 200, n-y: 160, bw: 0.012) = {
  let dx = 1.0 / (n-x - 1)
  let xs = range(n-x).map(i => i * dx)
  let ys = xs.map(x => fn(x))
  let weights = xs.map(x => gaussian(x, mu-x, sig-x) * dx)

  // Media e deviazione standard reali di Y
  let mean-y = range(n-x).fold(0.0, (acc, i) => acc + ys.at(i) * weights.at(i))
  let var-y = range(n-x).fold(0.0, (acc, i) => acc + calc.pow(ys.at(i) - mean-y, 2) * weights.at(i))
  let sig-y = calc.sqrt(var-y)

  // Approssimazione EKF (Taylor del primo ordine)
  let ekf-mean = fn(mu-x)
  let slope = dfn(mu-x)
  let ekf-sig = calc.abs(slope) * sig-x

  // Approssimazione UKF (2n + 1 = 3 sigma-points per n = 1)
  let spread = calc.sqrt(1.0 + lambda) * sig-x
  let sp-x = (mu-x - spread, mu-x, mu-x + spread)
  let sp-y = sp-x.map(x => fn(x))
  let w0 = lambda / (1.0 + lambda)
  let wi = 1.0 / (2.0 * (1.0 + lambda))
  let sp-w = (wi, w0, wi)

  let ukf-mean = range(3).fold(0.0, (acc, k) => acc + sp-w.at(k) * sp-y.at(k))
  let ukf-var = range(3).fold(0.0, (acc, k) => acc + sp-w.at(k) * calc.pow(sp-y.at(k) - ukf-mean, 2))
  let ukf-sig = calc.sqrt(ukf-var)

  // Griglia su y e valutazione delle densità
  let dy = 1.0 / (n-y - 1)
  let y-grid = range(n-y).map(j => j * dy)
  let py = y-grid.map(y => {
    range(n-x).fold(0.0, (acc, i) => acc + weights.at(i) * gaussian(y, ys.at(i), bw))
  })
  let py-gauss = y-grid.map(y => gaussian(y, mean-y, sig-y))
  let ekf-gauss = y-grid.map(y => gaussian(y, ekf-mean, ekf-sig))
  let ukf-gauss = y-grid.map(y => gaussian(y, ukf-mean, ukf-sig))

  // Limite orizzontale condiviso tra grafico EKF e UKF dello stesso pannello
  let max-py = calc.max(..py, ..py-gauss, ..ekf-gauss, ..ukf-gauss)

  (
    y-grid: y-grid,
    py: py,
    py-gauss: py-gauss,
    ekf-gauss: ekf-gauss,
    ukf-gauss: ukf-gauss,
    mean-y: mean-y,
    ekf-mean: ekf-mean,
    ukf-mean: ukf-mean,
    sp-x: sp-x,
    sp-y: sp-y,
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
    inset: (x: 4pt, y: 3pt),
    {
      set text(size: 6.2pt)
      grid(
        columns: (12pt, auto),
        column-gutter: 4pt,
        row-gutter: 2.2pt,
        align: (center + horizon, left + horizon),
        ..items.flatten()
      )
    },
  )
}

#let swatch-fill(col) = rect(width: 11pt, height: 5.5pt, fill: col.transparentize(72%), stroke: 0.8pt + col)
#let swatch-line(st) = box(width: 11pt, height: 5.5pt, line(start: (0pt, 2.75pt), end: (11pt, 2.75pt), stroke: st))
#let swatch-x(col) = text(fill: col, weight: "bold", size: 7pt)[$times$]
#let swatch-o(col) = box(width: 5.5pt, height: 5.5pt, circle(radius: 2.1pt, stroke: 1.0pt + col, fill: white))

// Grafico verticale p(y) per EKF o UKF (condividono lo stesso x-max nel pannello)
#let plot-py-method(res, method-gauss, method-mean, method-name, mean-name) = {
  let x-max = res.max-py * 1.42
  let y-grid = res.y-grid
  let py-pairs = range(y-grid.len()).map(i => (res.py.at(i), y-grid.at(i)))
  let py-poly = ((0.0, 0.0),) + py-pairs + ((0.0, 1.0),)
  let g-pairs = range(y-grid.len()).map(i => (res.py-gauss.at(i), y-grid.at(i)))
  let apx-pairs = range(y-grid.len()).map(i => (method-gauss.at(i), y-grid.at(i)))

  box(width: 3.65cm, height: 4.15cm)[
    #cetz.canvas({
      plot.plot(
        size: (2.8, 3.45),
        axis-style: "left",
        x-min: 0,
        x-max: x-max,
        y-min: 0,
        y-max: 1,
        x-ticks: (x-max * 0.25, x-max * 0.5, x-max * 0.75, x-max),
        y-ticks: (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7pt)[$p(y)$],
        y-label: text(size: 7pt)[$y$],
        {
          // Area riempita di p(y)
          plot.annotate({
            cetz.draw.line(
              ..py-poly,
              close: true,
              fill: col-py.transparentize(75%),
              stroke: none,
            )
          })
          plot.add(py-pairs, style: (stroke: st-py))
          plot.add(g-pairs, style: (stroke: st-py-gauss))
          plot.add(apx-pairs, style: (stroke: st-approx))

          // Media reale di p(y)
          plot.add(((0.0, res.mean-y), (x-max * 0.92, res.mean-y)), style: (stroke: st-mean))
          plot.add(((0.0, res.mean-y),), mark: "x", mark-size: 0.14, mark-style: (stroke: st-mean))

          // Media approssimata (EKF o UKF)
          plot.add(((0.0, method-mean), (x-max * 0.92, method-mean)), style: (stroke: st-mean-apx))
          plot.add(((0.0, method-mean),), mark: "o", mark-size: 0.14, mark-style: (stroke: (paint: col-approx, thickness: 1.1pt), fill: white))
        },
      )
    })
    #place(
      top + right,
      dx: -2pt,
      dy: 2pt,
      legend-box((
        (swatch-fill(col-py), [$p(y)$]),
        (swatch-line(st-py-gauss), [Gaussian of $p(y)$]),
        (swatch-line(st-mean), [Mean of $p(y)$]),
        (swatch-line(st-approx), method-name),
        (swatch-line(st-mean-apx), mean-name),
      )),
    )
  ]
}

// Grafico in alto a destra: g(x) e i 3 sigma-points proiettati sull'asse y
#let plot-gx-ukf(fn, res) = {
  box(width: 4.95cm, height: 4.15cm)[
    #cetz.canvas({
      plot.plot(
        size: (4.0, 3.45),
        axis-style: "left",
        x-min: 0,
        x-max: 1,
        y-min: 0,
        y-max: 1,
        x-ticks: (0.2, 0.4, 0.6, 0.8, 1.0),
        y-ticks: (0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7pt)[$x$],
        y-label: box(rotate(-90deg, reflow: true, text(size: 7pt)[$y = g(x)$])),
        {
          plot.add(domain: (0, 1), samples: 140, style: (stroke: st-func), fn)

          for k in range(3) {
            let sx = res.sp-x.at(k)
            let sy = res.sp-y.at(k)
            plot.add(((sx, 0.0), (sx, sy), (0.0, sy)), style: (stroke: st-proj))
          }

          plot.add(
            res.sp-x.map(sx => (sx, 0.0)),
            mark: "x",
            mark-size: 0.14,
            mark-style: (stroke: st-mean),
            style: (stroke: none),
          )

          plot.add(
            res.sp-y.map(sy => (0.0, sy)),
            mark: "o",
            mark-size: 0.14,
            mark-style: (stroke: (paint: col-approx, thickness: 1.1pt), fill: white),
            style: (stroke: none),
          )
        },
      )
    })
    #place(
      top + right,
      dx: -2pt,
      dy: 2pt,
      legend-box((
        (swatch-line(st-func), [Function $g(x)$]),
        (swatch-x(col-mean), [Sigma-points]),
        (swatch-o(col-approx), [$g($sigma points$)$]),
      )),
    )
  ]
}

// Grafico in basso a destra: densità gaussiana p(x)
#let plot-px-ukf(mu-x, sig-x) = {
  let peak = gaussian(mu-x, mu-x, sig-x)
  let y-max = peak * 1.48
  box(width: 4.95cm, height: 2.45cm)[
    #cetz.canvas({
      plot.plot(
        size: (4.0, 1.8),
        axis-style: "left",
        x-min: 0,
        x-max: 1,
        y-min: 0,
        y-max: y-max,
        x-ticks: (0.2, 0.4, 0.6, 0.8, 1.0),
        y-ticks: (y-max * 0.2, y-max * 0.4, y-max * 0.6, y-max * 0.8, y-max),
        x-format: _ => [],
        y-format: _ => [],
        x-label: text(size: 7pt)[$x$],
        y-label: box(rotate(-90deg, reflow: true, text(size: 7pt)[$p(x)$])),
        {
          plot.add(
            domain: (0, 1),
            samples: 180,
            fill: true,
            style: (stroke: st-px, fill: col-px.transparentize(75%)),
            x => gaussian(x, mu-x, sig-x),
          )
          plot.add(((mu-x, 0.0), (mu-x, peak)), style: (stroke: st-mean))
          plot.add(((mu-x, 0.0),), mark: "x", mark-size: 0.14, mark-style: (stroke: st-mean))
        },
      )
    })
    #place(
      top + right,
      dx: -2pt,
      dy: 2pt,
      legend-box((
        (swatch-fill(col-px), [$p(x)$]),
        (swatch-x(col-mean), [Mean $mu$]),
      )),
    )
  ]
}

// Riquadro del sottopannello (a) o (b)
#let subpanel(label, body) = {
  grid(
    columns: (auto, auto),
    column-gutter: 5pt,
    align: (top, top),
    text(weight: "bold", size: 9.5pt)[#label],
    box(
      stroke: 0.7pt + luma(40),
      inset: (x: 6pt, y: 6pt),
      body,
    ),
  )
}

// ---------------------------------------------------------------------------
// 4. Funzione principale esportata
// ---------------------------------------------------------------------------
#let fig-ukf-nonlinearity(
  mu-a: 0.65,
  mu-b: 0.35,
  sig-x: 0.085,
  lambda: 1.2,
  caption: auto,
) = {
  let res-a = transform-ekf-ukf(g-nonlinear, g-nonlinear-deriv, mu-a, sig-x, lambda: lambda, bw: 0.012)
  let res-b = transform-ekf-ukf(g-nonlinear, g-nonlinear-deriv, mu-b, sig-x, lambda: lambda, bw: 0.012)

  let fig-caption = if caption == auto [
    Linearization results for the UKF depending on the mean of the original Gaussian. The results of the EKF linearization are also shown for comparison (cf. @fig:ekf-nonlinearity). The sigma point linearization incurs smaller approximation errors, as can be seen by the stronger similarity between the dashed magenta and the solid purple Gaussians.
  ] else {
    caption
  }

  figure(
    stack(
      dir: ttb,
      spacing: 9pt,
      // Pannello (a): Media spostata a destra (mu = 0.65)
      subpanel("(a)", grid(
        columns: (auto, auto, auto),
        column-gutter: 6pt,
        row-gutter: 5pt,
        plot-py-method(res-a, res-a.ekf-gauss, res-a.ekf-mean, [EKF Gaussian], [Mean of EKF]),
        plot-py-method(res-a, res-a.ukf-gauss, res-a.ukf-mean, [UKF Gaussian], [Mean of UKF]),
        plot-gx-ukf(g-nonlinear, res-a),
        [],
        [],
        plot-px-ukf(mu-a, sig-x),
      )),
      // Pannello (b): Media spostata a sinistra (mu = 0.35)
      subpanel("(b)", grid(
        columns: (auto, auto, auto),
        column-gutter: 6pt,
        row-gutter: 5pt,
        plot-py-method(res-b, res-b.ekf-gauss, res-b.ekf-mean, [EKF Gaussian], [Mean of EKF]),
        plot-py-method(res-b, res-b.ukf-gauss, res-b.ukf-mean, [UKF Gaussian], [Mean of UKF]),
        plot-gx-ukf(g-nonlinear, res-b),
        [],
        [],
        plot-px-ukf(mu-b, sig-x),
      )),
    ),
    caption: fig-caption,
  )
}