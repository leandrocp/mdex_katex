defmodule MDExKatexTest do
  use ExUnit.Case

  setup do
    markdown = """
    # Einstein's Formula

    ```math
    E = mc^2
    ```
    """

    [document: MDEx.new(markdown: markdown)]
  end

  test "default options", %{document: document} do
    document = MDExKatex.attach(document)
    html = MDEx.to_html!(document)

    # Check that KaTeX CSS and JS are loaded
    assert html =~
             ~s(<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">)

    assert html =~
             ~s(<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>)

    assert html =~
             ~s(<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/contrib/auto-render.min.js")

    # Check that the div is created with correct attributes and escaped LaTeX
    assert html =~
             ~s(<div id="katex-1" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="E = mc^2"></div>)

    # Check that the formula is in the output
    assert html =~ "E = mc^2"

    # Check the heading
    assert html =~ "<h1>Einstein's Formula</h1>"
  end

  test "custom init", %{document: document} do
    document =
      MDExKatex.attach(document, katex_init: "<script>console.log('__test__')</script>")

    html = MDEx.to_html!(document)
    assert html =~ "__test__"
  end

  test "custom init replaces default init", %{document: document} do
    custom_init = "<script>window.customKaTeX = true;</script>"
    document = MDExKatex.attach(document, katex_init: custom_init)

    html = MDEx.to_html!(document)

    assert html =~ "window.customKaTeX = true"
    refute html =~ "cdn.jsdelivr.net/npm/katex"
  end

  test "empty string init skips initialization", %{document: document} do
    document = MDExKatex.attach(document, katex_init: "")

    html = MDEx.to_html!(document)

    refute html =~ "<script"
    refute html =~ "<link"

    assert html =~
             ~s(<div id="katex-1" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="E = mc^2"></div>)
  end

  test "nil init uses default init", %{document: document} do
    document = MDExKatex.attach(document, katex_init: nil)

    html = MDEx.to_html!(document)

    assert html =~ "cdn.jsdelivr.net/npm/katex"
    assert html =~ "katex.render(latex, el"
  end

  test "custom katex_options with keyword list", %{document: document} do
    document =
      MDExKatex.attach(document,
        katex_options: [trust: false, throwOnError: true, output: "mathml"]
      )

    html = MDEx.to_html!(document)

    assert html =~ "Object.assign({displayMode: displayMode}, {"
    assert html =~ ~s("output": "mathml")
    assert html =~ ~s("throwOnError": true)
    assert html =~ ~s("trust": false)
  end

  test "custom katex_options with map", %{document: document} do
    document =
      MDExKatex.attach(document,
        katex_options: %{"errorColor" => "#cc0000", :strict => "warn", :maxExpand => 50}
      )

    html = MDEx.to_html!(document)

    assert html =~ ~s("errorColor": "#cc0000")
    assert html =~ ~s("strict": "warn")
    assert html =~ ~s("maxExpand": 50)
    assert html =~ ~s("throwOnError": false)
    assert html =~ ~s("trust": true)
  end

  test "custom katex_options with raw JavaScript", %{document: document} do
    document =
      MDExKatex.attach(document,
        katex_options: "{strict: (errorCode) => 'ignore', trust: (context) => false}"
      )

    html = MDEx.to_html!(document)

    assert html =~
             "Object.assign({displayMode: displayMode}, {strict: (errorCode) => 'ignore', trust: (context) => false})"
  end

  test "custom katex_block_attrs", %{document: document} do
    block_attrs = fn seq -> ~s(id="custom-#{seq}" class="formula" data-type="math") end
    document = MDExKatex.attach(document, katex_block_attrs: block_attrs)

    html = MDEx.to_html!(document)

    assert html =~
             ~s(<div id="custom-1" class="formula" data-type="math" data-math-style="display" data-latex="E = mc^2"></div>)

    refute html =~ ~s(phx-update="ignore")
  end

  test "katex_block_attrs with LiveView hook", %{document: document} do
    block_attrs = fn seq ->
      ~s(id="katex-#{seq}" class="katex-block" phx-hook="KaTeXHook" phx-update="ignore")
    end

    document = MDExKatex.attach(document, katex_block_attrs: block_attrs)

    html = MDEx.to_html!(document)

    assert html =~ ~s(phx-hook="KaTeXHook")
    assert html =~ ~s(phx-update="ignore")
    assert html =~ ~s(id="katex-1")
  end

  test "katex_block_attrs increments sequence for multiple blocks" do
    markdown = """
    ```math
    E = mc^2
    ```

    ```math
    \\int_0^\\infty e^{-x} dx = 1
    ```

    ```math
    x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}
    ```
    """

    block_attrs = fn seq -> ~s(id="formula-#{seq}" class="katex-block") end

    html =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach(katex_block_attrs: block_attrs)
      |> MDEx.to_html!()

    assert html =~
             ~s(<div id="formula-1" class="katex-block" data-math-style="display" data-latex="E = mc^2"></div>)

    assert html =~
             ~s(<div id="formula-2" class="katex-block" data-math-style="display" data-latex="\\int_0^\\infty e^{-x} dx = 1"></div>)

    assert html =~
             ~s(<div id="formula-3" class="katex-block" data-math-style="display" data-latex="x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}"></div>)
  end

  test "combined custom options", %{document: document} do
    custom_init = "<!-- katex already loaded -->"
    block_attrs = fn seq -> ~s(id="math-#{seq}" class="math-formula") end

    document =
      MDExKatex.attach(document,
        katex_init: custom_init,
        katex_block_attrs: block_attrs
      )

    html = MDEx.to_html!(document)

    assert html =~ "<!-- katex already loaded -->"

    assert html =~
             ~s(<div id="math-1" class="math-formula" data-math-style="display" data-latex="E = mc^2"></div>)

    refute html =~ "cdn.jsdelivr.net/npm/katex"
    refute html =~ ~s(phx-update="ignore")
  end

  test "custom katex_inline_attrs" do
    markdown = "Euler wrote $e^{i\\pi} + 1 = 0$"
    inline_attrs = fn seq -> ~s(id="inline-#{seq}" class="math-inline" data-type="inline") end

    html =
      MDEx.new(markdown: markdown, extension: [math_dollars: true])
      |> MDExKatex.attach(katex_inline_attrs: inline_attrs)
      |> MDEx.to_html!()

    assert html =~
             ~s(<p>Euler wrote <span id="inline-1" class="math-inline" data-type="inline" data-math-style="inline" data-latex="e^{i\\pi} + 1 = 0"></span></p>)

    refute html =~ ~s(class="katex-inline")
  end

  test "HTML entities are escaped to prevent XSS" do
    markdown = """
    ```math
    <script>alert('xss')</script>
    ```
    """

    html =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach()
      |> MDEx.to_html!()

    # Should be escaped
    assert html =~ "&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;"
    # Should NOT contain unescaped script tags
    refute html =~ "<script>alert('xss')</script>"
  end

  test "special LaTeX characters are properly handled" do
    markdown = """
    ```math
    \\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}
    ```
    """

    html =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach()
      |> MDEx.to_html!()

    assert html =~
             "data-math-style=\"display\" data-latex=\"\\sum_{i=1}^{n} i = \\frac{n(n+1)}{2}\""
  end

  test "multiline formulas are preserved" do
    markdown = """
    ```math
    \\begin{aligned}
    f(x) &= x^2 \\\\
    g(x) &= \\sqrt{x}
    \\end{aligned}
    ```
    """

    html =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach()
      |> MDEx.to_html!()

    # Check that newlines are preserved in some form
    assert html =~ "\\begin{aligned}"
    assert html =~ "\\end{aligned}"
    assert html =~ "f(x)"
    assert html =~ "g(x)"
  end

  test "complex mathematical expressions" do
    markdown = """
    ```math
    \\oint_C \\vec{E} \\cdot d\\vec{l} = -\\frac{d}{dt} \\iint_S \\vec{B} \\cdot d\\vec{A}
    ```
    """

    html =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach()
      |> MDEx.to_html!()

    assert html =~ "\\oint_C"
    assert html =~ "\\vec{E}"
    assert html =~ "\\iint_S"
    assert html =~ "\\vec{B}"
  end

  test "non-math code blocks are not affected" do
    markdown = """
    ```elixir
    def hello, do: "world"
    ```

    ```math
    E = mc^2
    ```

    ```python
    print("hello")
    ```
    """

    html =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach()
      |> MDEx.to_html!()

    # Math block should be transformed
    assert html =~ ~s(data-math-style="display" data-latex="E = mc^2")

    # Other code blocks should remain as code blocks (may be syntax highlighted)
    assert html =~ "language-elixir"
    assert html =~ "language-python"
    assert html =~ "def"
    assert html =~ "hello"
    assert html =~ "print"
  end

  test "katex code fence is recognized" do
    markdown = """
    # Formula

    ```katex
    E = mc^2
    ```
    """

    html =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach()
      |> MDEx.to_html!()

    assert html =~
             ~s(<div id="katex-1" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="E = mc^2"></div>)

    assert html =~ "cdn.jsdelivr.net/npm/katex"
  end

  test "both math and katex fences work together" do
    markdown = """
    ```math
    E = mc^2
    ```

    ```katex
    F = ma
    ```

    ```math
    x = \\frac{-b}{2a}
    ```
    """

    html =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach()
      |> MDEx.to_html!()

    assert html =~
             ~s(<div id="katex-1" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="E = mc^2"></div>)

    assert html =~
             ~s(<div id="katex-2" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="F = ma"></div>)

    assert html =~
             ~s(<div id="katex-3" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="x = \\frac{-b}{2a}"></div>)
  end

  test "katex fence with custom attributes" do
    markdown = """
    ```katex
    \\sum_{i=1}^{n} i
    ```
    """

    block_attrs = fn seq -> ~s(id="formula-#{seq}" class="math-formula") end

    html =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach(katex_block_attrs: block_attrs)
      |> MDEx.to_html!()

    assert html =~
             ~s(<div id="formula-1" class="math-formula" data-math-style="display" data-latex="\\sum_{i=1}^{n} i"></div>)
  end

  test "dollar math" do
    markdown = """
    This sentence contains inline math: $y = 2x + 3$

    $$y = 2x + 3$$
    """

    html =
      MDEx.new(markdown: markdown, extension: [math_dollars: true])
      |> MDExKatex.attach()
      |> MDEx.to_html!()

    assert html =~
             ~s(<p>This sentence contains inline math: <span id=\"katex-inline-1\" class=\"katex-inline\" phx-update=\"ignore\" data-math-style="inline" data-latex=\"y = 2x + 3\"></span></p>)

    assert html =~
             ~s(<div id="katex-2" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="y = 2x + 3"></div>)
  end

  test "dollar math and code block" do
    markdown = """
    This sentence contains inline math: $y = 2x + 3$

    $$y = 2x + 3$$

    ```math
    E = mc^2
    ```
    """

    html =
      MDEx.new(markdown: markdown, extension: [math_dollars: true])
      |> MDExKatex.attach()
      |> MDEx.to_html!()

    assert html =~
             ~s(<p>This sentence contains inline math: <span id=\"katex-inline-1\" class=\"katex-inline\" phx-update=\"ignore\" data-math-style="inline" data-latex=\"y = 2x + 3\"></span></p>)

    assert html =~
             ~s(<div id="katex-2" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="y = 2x + 3"></div>)

    assert html =~
             ~s(<div id="katex-3" class="katex-block" phx-update="ignore" data-math-style="display" data-latex="E = mc^2"></div>)
  end
end
