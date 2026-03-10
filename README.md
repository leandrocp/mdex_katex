# MDExKatex

[![Hex.pm](https://img.shields.io/hexpm/v/mdex_katex)](https://hex.pm/packages/mdex_katex)
[![Hexdocs](https://img.shields.io/badge/hexdocs-latest-blue.svg)](https://hexdocs.pm/mdex_katex)

<!-- MDOC -->

[MDEx](https://mdelixir.dev) plugin for [KaTeX](https://katex.org).

## Usage

````elixir
Mix.install([
  {:mdex_katex, "~> 0.1"}
])

markdown = """
# Einstein's Mass-Energy Equivalence

In text, Euler's identity is $e^{i\\pi} + 1 = 0$.

```math
E = mc^2
```

The quadratic formula:

```math
x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}
```
"""

mdex =
  MDEx.new(markdown: markdown, extension: [math_dollars: true])
  |> MDExKatex.attach()

MDEx.to_html!(mdex) |> IO.puts()
#=>
# <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
# <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>
# <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/contrib/auto-render.min.js" onload="renderMathInElement(document.body, {delimiters: [{left: '$$', right: '$$', display: true}]});"></script>
# <script>
#   document.addEventListener("DOMContentLoaded", () => {
#     document.querySelectorAll('.katex-block, .katex-inline').forEach(el => {
#       const latex = el.dataset.latex;
#       const mathStyle = el.dataset.mathStyle;
#       if (latex && mathStyle) {
#         const displayMode = mathStyle == "display" ? true : false
#         katex.render(latex, el, {
#           displayMode: displayMode,
#           throwOnError: false,
#           trust: true,
#         });
#       }
#     });
#   });
# </script>
# <h1>Einstein's Mass-Energy Equivalence</h1>
# <p>In text, Euler's identity is <span id="katex-inline-1" class="katex-inline" phx-update="ignore" data-math-style="inline" data-latex="e^{i\pi} + 1 = 0"></span>.</p>
# <div id="katex-1" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="E = mc^2"></div>
# <p>The quadratic formula:</p>
# <div id="katex-2" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}"></div>
````

**Note:** `math` and `katex` code fences render as display math. Dollar math is also supported when `MDEx` enables `extension: [math_dollars: true]`; inline formulas use the `.katex-inline` class and display formulas use `.katex-block`.

Quick reference:

````markdown
Inline math: $e^{i\pi} + 1 = 0$

```math
E = mc^2
```
````

See [attach/2](https://hexdocs.pm/mdex_katex/MDExKatex.html#attach/2) for integration examples (static HTML, Phoenix LiveView, custom styling) and configuration options.
