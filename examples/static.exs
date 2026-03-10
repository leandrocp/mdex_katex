Mix.install([
  {:mdex_katex, path: ".."}
])

markdown = """
# Mathematical Formulas

Inline math example: Euler's identity is $e^{i\\pi} + 1 = 0$ and the slope is $m = \\frac{y_2 - y_1}{x_2 - x_1}$.

## Einstein's Mass-Energy Equivalence

```math
E = mc^2
```

## Maxwell's Equations

Gauss's Law:

```math
\\nabla \\cdot \\vec{E} = \\frac{\\rho}{\\epsilon_0}
```

Faraday's Law:

```math
\\nabla \\times \\vec{E} = -\\frac{\\partial \\vec{B}}{\\partial t}
```

## Quadratic Formula

```math
x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}
```

## Euler's Identity

```math
e^{i\\pi} + 1 = 0
```

## Schrödinger Equation

```math
i\\hbar\\frac{\\partial}{\\partial t}\\Psi(\\vec{r},t) = \\hat{H}\\Psi(\\vec{r},t)
```
"""

mdex = MDEx.new(markdown: markdown, extension: [math_dollars: true]) |> MDExKatex.attach()
body_content = MDEx.to_html!(mdex)

# Wrap in proper HTML5 document structure for KaTeX to work (requires standards mode, not quirks mode)
html = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mathematical Formulas</title>
  <style>
    :root {
      --bg: #f4f7fb;
      --surface: rgba(255, 255, 255, 0.88);
      --surface-border: rgba(148, 163, 184, 0.22);
      --text: #142033;
      --muted: #526074;
      --accent: #1d4ed8;
      --accent-soft: rgba(29, 78, 216, 0.1);
      --math-bg: linear-gradient(180deg, #f8fbff 0%, #f2f6fb 100%);
      --shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
    }
    * {
      box-sizing: border-box;
    }
    html {
      background:
        radial-gradient(circle at top, rgba(125, 211, 252, 0.22), transparent 34%),
        linear-gradient(180deg, #f8fbff 0%, var(--bg) 100%);
    }
    body {
      max-width: 960px;
      margin: 0 auto;
      padding: 3rem 1.5rem 4rem;
      font-family: "Iowan Old Style", "Palatino Linotype", "Book Antiqua", Georgia, serif;
      line-height: 1.7;
      color: var(--text);
    }
    main {
      background: var(--surface);
      border: 1px solid var(--surface-border);
      border-radius: 24px;
      box-shadow: var(--shadow);
      backdrop-filter: blur(10px);
      padding: 2.5rem 2.25rem;
    }
    .eyebrow {
      display: inline-block;
      margin-bottom: 1rem;
      padding: 0.4rem 0.75rem;
      border-radius: 999px;
      background: var(--accent-soft);
      color: var(--accent);
      font: 600 0.72rem/1.1 system-ui, -apple-system, sans-serif;
      letter-spacing: 0.14em;
      text-transform: uppercase;
    }
    h1 {
      font-size: clamp(2.25rem, 4vw, 3.1rem);
      font-weight: 700;
      line-height: 1.1;
      letter-spacing: -0.03em;
      margin: 0 0 1rem;
      color: var(--text);
    }
    h2 {
      font-size: 1.35rem;
      font-weight: 600;
      margin-top: 2.5rem;
      margin-bottom: 0.8rem;
      color: var(--text);
    }
    p {
      margin: 1rem 0;
      color: var(--muted);
    }
    .katex-block {
      padding: 1.4rem 1.5rem;
      margin: 1.4rem 0 1.8rem;
      background: var(--math-bg);
      border: 1px solid rgba(96, 165, 250, 0.22);
      border-left: 4px solid var(--accent);
      border-radius: 16px;
      overflow-x: auto;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.8);
    }
    .katex-inline {
      padding: 0 0.18rem;
      color: var(--accent);
      font-size: 1.02em;
    }
    .katex-display {
      margin: 0;
    }
    @media (max-width: 640px) {
      body {
        padding: 1rem 0.8rem 2rem;
      }
      main {
        padding: 1.4rem 1rem;
        border-radius: 18px;
      }
      .katex-block {
        padding: 1rem;
      }
    }
  </style>
</head>
<body>
<main>
<div class="eyebrow">MDEx + KaTeX</div>
#{body_content}
</main>
</body>
</html>
"""

File.write!("static.html", html)
