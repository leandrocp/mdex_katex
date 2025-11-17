Mix.install([
  {:mdex_katex, path: ".."}
])

markdown = """
# Mathematical Formulas

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

mdex = MDEx.new(markdown: markdown) |> MDExKatex.attach()
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
    body {
      max-width: 900px;
      margin: 0 auto;
      padding: 3rem 2rem;
      font-family: system-ui, -apple-system, sans-serif;
      line-height: 1.6;
      background: #ffffff;
    }
    h1 {
      font-size: 2.5rem;
      font-weight: 700;
      margin-bottom: 2rem;
      color: #1e293b;
      border-bottom: 3px solid #3b82f6;
      padding-bottom: 1rem;
    }
    h2 {
      font-size: 1.5rem;
      font-weight: 600;
      margin-top: 3rem;
      margin-bottom: 1rem;
      color: #334155;
    }
    p {
      margin: 1rem 0;
      color: #475569;
    }
    .katex-block {
      padding: 2rem;
      margin: 2rem 0;
      background: #f8fafc;
      border-left: 4px solid #3b82f6;
      border-radius: 0.5rem;
      overflow-x: auto;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }
  </style>
</head>
<body>
#{body_content}
</body>
</html>
"""

File.write!("static.html", html)
