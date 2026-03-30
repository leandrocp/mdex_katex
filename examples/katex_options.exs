Mix.install([
  {:mdex_katex, path: ".."}
])

markdown = ~S"""
# KaTeX Options Example

This page customizes KaTeX with `katex_options`.

Inline math still works: $e^{i\pi} + 1 = 0$.

## Display Math

```math
\int_0^\infty e^{-x} dx = 1
```

## Invalid LaTeX

With `throwOnError: false`, invalid input is rendered with KaTeX error styling instead of crashing:

```math
\invalid
```
"""

mdex =
  MDEx.new(markdown: markdown, extension: [math_dollars: true])
  |> MDExKatex.attach(
    katex_options: [
      throwOnError: false,
      errorColor: "#b91c1c",
      trust: false,
      strict: "warn",
      output: "htmlAndMathml"
    ]
  )

body_content = MDEx.to_html!(mdex)

html = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>KaTeX Options Example</title>
  <style>
    :root {
      --bg: #f8fafc;
      --surface: #ffffff;
      --text: #0f172a;
      --muted: #475569;
      --accent: #7c3aed;
      --accent-soft: rgba(124, 58, 237, 0.1);
      --border: rgba(148, 163, 184, 0.24);
      --shadow: 0 20px 50px rgba(15, 23, 42, 0.08);
    }
    * {
      box-sizing: border-box;
    }
    body {
      margin: 0;
      padding: 2rem 1rem 3rem;
      background:
        radial-gradient(circle at top, rgba(196, 181, 253, 0.28), transparent 30%),
        var(--bg);
      color: var(--text);
      font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }
    main {
      max-width: 860px;
      margin: 0 auto;
      padding: 2rem;
      background: var(--surface);
      border: 1px solid var(--border);
      border-radius: 24px;
      box-shadow: var(--shadow);
    }
    .eyebrow {
      display: inline-block;
      margin-bottom: 1rem;
      padding: 0.35rem 0.7rem;
      border-radius: 999px;
      background: var(--accent-soft);
      color: var(--accent);
      font-size: 0.75rem;
      font-weight: 700;
      letter-spacing: 0.12em;
      text-transform: uppercase;
    }
    .note {
      margin: 1rem 0 1.5rem;
      padding: 1rem 1.1rem;
      background: #faf5ff;
      border: 1px solid rgba(124, 58, 237, 0.16);
      border-radius: 16px;
      color: var(--muted);
    }
    .note code {
      color: var(--text);
    }
    .katex-block {
      margin: 1.25rem 0 1.75rem;
      padding: 1.25rem;
      border-radius: 18px;
      background: linear-gradient(180deg, #fcfcff 0%, #f6f3ff 100%);
      border: 1px solid rgba(124, 58, 237, 0.14);
      overflow-x: auto;
    }
    .katex-inline {
      color: var(--accent);
    }
    h1 {
      margin: 0 0 0.75rem;
      font-size: clamp(2rem, 4vw, 2.8rem);
      line-height: 1.05;
    }
    h2 {
      margin-top: 2rem;
    }
    p {
      color: var(--muted);
      line-height: 1.7;
    }
    @media (max-width: 640px) {
      main {
        padding: 1.2rem;
        border-radius: 18px;
      }
    }
  </style>
</head>
<body>
<main>
  <div class="eyebrow">MDEx + KaTeX</div>
  <div class="note">
    Using <code>katex_options: [throwOnError: false, errorColor: "#b91c1c", trust: false, strict: "warn"]</code>.
    See https://katex.org/docs/options.
  </div>
  #{body_content}
</main>
</body>
</html>
"""

File.write!("katex_options.html", html)
