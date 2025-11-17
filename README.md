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

```math
E = mc^2
```

The quadratic formula:

```math
x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}
```
"""

mdex = MDEx.new(markdown: markdown) |> MDExKatex.attach()

MDEx.to_html!(mdex) |> IO.puts()
#=>
# <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
# <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>
# <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/contrib/auto-render.min.js" onload="renderMathInElement(document.body, {delimiters: [{left: '$$', right: '$$', display: true}]});"></script>
# <script>
#   document.addEventListener("DOMContentLoaded", () => {
#     document.querySelectorAll('.katex-block').forEach(el => {
#       const latex = el.dataset.latex;
#       if (latex) {
#         katex.render(latex, el, {
#           displayMode: true,
#           throwOnError: false,
#           trust: true
#         });
#       }
#     });
#   });
# </script>
# <h1>Einstein's Mass-Energy Equivalence</h1>
# <div id="katex-1" class="katex-block" phx-update="ignore" data-latex="E = mc^2"></div>
# <p>The quadratic formula:</p>
# <div id="katex-2" class="katex-block" phx-update="ignore" data-latex="x = \frac{-b \pm \sqrt{b^2 - 4ac}}{2a}"></div>
````

**Note:** Both `math` and `katex` code fences are supported.

See [attach/2](https://hexdocs.pm/mdex_katex/MDExKatex.html#attach/2) for integration examples (static HTML, Phoenix LiveView, custom styling) and configuration options.
