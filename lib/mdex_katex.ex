defmodule MDExKatex do
  @external_resource "README.md"

  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC -->")
             |> Enum.fetch!(1)

  alias MDEx.Document

  @default_init """
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/contrib/auto-render.min.js" onload="renderMathInElement(document.body, {delimiters: [{left: '$$', right: '$$', display: true}]});"></script>
  <script>
    document.addEventListener("DOMContentLoaded", () => {
      document.querySelectorAll('.katex-block, .katex-inline').forEach(el => {
        const latex = el.dataset.latex;
        const mathStyle = el.dataset.mathStyle;
        if (latex && mathStyle) {
          const displayMode = mathStyle == "display" ? true : false
          katex.render(latex, el, {
            displayMode: displayMode,
            throwOnError: false,
            trust: true,
          });
        }
      });
    });
  </script>
  """

  @type katex_block_attrs :: (seq :: pos_integer() -> String.t())
  @type katex_inline_attrs :: (seq :: pos_integer() -> String.t())

  @doc """
  Attaches the MDExKatex plugin into the MDEx document.

  - KaTeX is loaded from https://www.jsdelivr.com/package/npm/katex
  - Renders mathematical expressions using LaTeX syntax
  - Recognizes both `math` and `katex` code fences, and dollar math when the [extension option](https://hexdocs.pm/mdex/MDEx.Document.html#t:extension_options/0) `math_dollars` is true.

  ## Options
    - `:katex_block_attrs` (`t:katex_block_attrs/0`) - Function that generates the display math tag attributes for `math`/`katex` code fences and `$$...$$` expressions.
    - `:katex_inline_attrs` (`t:katex_inline_attrs/0`) - Function that generates the inline math tag attributes for `$...$` expressions.
    - `:katex_init` (`t:String.t/0`) - The HTML tag(s) to inject into the document to initialize KaTeX. If `nil`, the default script is used (see below).

  ### :katex_block_attrs

  Whenever a display math node is found, it gets converted into a `<div>` tag using the following function to generate its attributes:


      block_attrs = fn seq -> ~s(id="katex-\#\{seq}" class="katex-block" phx-update="ignore") end
      mdex = MDEx.new() |> MDExKatex.attach(katex_block_attrs: block_attrs)

  Which results in:

      <div id="katex-1" class="katex-block" data-math-style="display" data-latex="E = mc^2" phx-update="ignore"></div>

  You can override it to include or manipulate the attributes but it's important to maintain unique IDs for each instance,
  otherwise the KaTeX rendering will not work correctly, for eg:

      fn seq -> ~s(id="katex-\#\{seq}" class="katex-block formula" phx-hook="KaTeXHook" phx-update="ignore") end

  ### :katex_inline_attrs

  Whenever inline dollar math is found, it gets converted into a `<span>` tag using the following function to generate its attributes:


      inline_attrs = fn seq -> ~s(id="katex-inline-\#\{seq}" class="katex-inline" phx-update="ignore") end
      mdex = MDEx.new(markdown: "Euler wrote $e^{i\\pi} + 1 = 0$", extension: [math_dollars: true])
      |> MDExKatex.attach(katex_inline_attrs: inline_attrs)

  Which results in:

      <p>Euler wrote <span id="katex-inline-1" class="katex-inline" data-math-style="inline" data-latex="e^{i\pi} + 1 = 0" phx-update="ignore"></span></p>

  ### :katex_init

  The option `:katex_init` can be used to manipulate how KaTeX is initialized. By default, the following script is injected into the top of the document:

  ```html
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/contrib/auto-render.min.js"></script>
  <script>
    document.addEventListener("DOMContentLoaded", () => {
      document.querySelectorAll('.katex-block, .katex-inline').forEach(el => {
        const latex = el.dataset.latex;
        const mathStyle = el.dataset.mathStyle;
        if (latex && mathStyle) {
          const displayMode = mathStyle == "display" ? true : false
          katex.render(latex, el, {
            displayMode: displayMode,
            throwOnError: false,
            trust: true,
          });
        }
      });
    });
  </script>
  ```

  That script works well on static documents but you'll need to adjust it to initialize KaTeX in environments
  that requires waiting for the DOM to be ready.

  ## Examples

  See the [examples](https://github.com/leandrocp/mdex_katex/tree/main/examples) directory for complete working examples.

  ### Static HTML

  The output includes all necessary scripts and can be used directly:

  ```elixir
  html = MDEx.new(markdown: markdown, extension: [math_dollars: true]) |> MDExKatex.attach() |> MDEx.to_html!()
  File.write!("output.html", html)
  ```

  For embedding in existing HTML documents, extract content between initialization scripts and your markdown content.

  See [examples/static.exs](https://github.com/leandrocp/mdex_katex/blob/main/examples/static.exs) for a complete working example.

  ### Phoenix LiveView

  To use MDExKatex with Phoenix LiveView, you can:

  1. Load KaTeX (via CDN or npm)
  2. Create a LiveView hook to render formulas
  3. Configure MDExKatex with the appropriate attributes

  ### Option 1: Using CDN

  In your layout:

  ```html
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>
  ```

  ### Option 2: Using npm

  Install KaTeX as a dependency:

  ```bash
  cd assets && npm install katex
  ```

  In your `assets/js/app.js`:

  ```javascript
  import katex from 'katex';
  import 'katex/dist/katex.min.css';

  let hooks = {
    KaTeXHook: {
      mounted() {
        const latex = this.el.dataset.latex;
        const mathStyle = this.el.dataset.mathStyle;
        if (latex && mathStyle) {
          const displayMode = mathStyle == "display" ? true : false
          katex.render(latex, this.el, {
            displayMode: displayMode,
            throwOnError: false,
            trust: true,
          });
        }
      },
    }
  }

  let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: hooks})
  ```

  ### Using in LiveView

  ```elixir
  html =
    MDEx.new(markdown: markdown, extension: [math_dollars: true])
    |> MDExKatex.attach(
      katex_init: "", # already initialized
      katex_block_attrs: fn seq ->
        ~s(id="katex-\#\{seq\}" class="katex-block" phx-hook="KaTeXHook" phx-update="ignore")
      end,
      katex_inline_attrs: fn seq ->
        ~s(id="katex-inline-\#\{seq\}" class="katex-inline" phx-hook="KaTeXHook" phx-update="ignore")
      end
    )
    |> MDEx.to_html!()

  assign(socket, html: {:safe, html})}
  ```

  Note that you can attach a JS hook per formula or in a parent element to handle all formulas at once, depending on your needs.

  See [examples/live_view.exs](https://github.com/leandrocp/mdex_katex/blob/main/examples/live_view.exs) for a complete working example with both individual hooks and global hooks patterns.

  ### Custom Styling

  Target `.katex-block` for display math and `.katex-inline` for inline math:

  ```css
  .katex-block {
    padding: 1em;
    margin: 1em 0;
    background: #f5f5f5;
    border-radius: 4px;
  }

  .katex-inline {
    padding: 0;
    background: transparent;
  }
  ```
  """
  @spec attach(Document.t(), keyword()) :: Document.t()
  def attach(document, options \\ []) do
    document
    |> Document.register_options([
      :katex_init,
      :katex_block_attrs,
      :katex_inline_attrs
    ])
    |> Document.put_options(options)
    |> Document.append_steps(enable_unsafe: &enable_unsafe/1)
    |> Document.append_steps(inject_init: &inject_init/1)
    |> Document.append_steps(update_code_blocks: &update_code_blocks/1)
  end

  defp enable_unsafe(document) do
    Document.put_render_options(document, unsafe: true)
  end

  defp inject_init(document) do
    init = Document.get_option(document, :katex_init) || @default_init
    Document.put_node_in_document_root(document, %MDEx.HtmlBlock{literal: init}, :top)
  end

  defp update_code_blocks(document) do
    block_attrs =
      Document.get_option(document, :katex_block_attrs) ||
        fn seq ->
          ~s(id="katex-#{seq}" class="katex-block" phx-update="ignore")
        end

    inline_attrs =
      Document.get_option(document, :katex_inline_attrs) ||
        fn seq ->
          ~s(id="katex-inline-#{seq}" class="katex-inline" phx-update="ignore")
        end

    {document, _} =
      MDEx.traverse_and_update(document, 1, fn
        %MDEx.CodeBlock{info: info} = node, acc when info in ["math", "katex"] ->
          # Escape HTML entities in LaTeX to prevent XSS
          escaped_latex = node.literal |> String.trim() |> escape_html()

          div =
            "<div #{block_attrs.(acc)} data-math-style=\"display\" data-latex=\"#{escaped_latex}\"></div>"

          node = %MDEx.HtmlBlock{literal: div, nodes: node.nodes}
          {node, acc + 1}

        %MDEx.Math{dollar_math: true, display_math: true} = node, acc ->
          escaped_latex = node.literal |> String.trim() |> escape_html()

          div =
            "<div #{block_attrs.(acc)} data-math-style=\"display\" data-latex=\"#{escaped_latex}\"></div>"

          node = %MDEx.HtmlBlock{literal: div}
          {node, acc + 1}

        %MDEx.Math{dollar_math: true, display_math: false} = node, acc ->
          escaped_latex = node.literal |> String.trim() |> escape_html()

          span =
            "<span #{inline_attrs.(acc)} data-math-style=\"inline\" data-latex=\"#{escaped_latex}\"></span>"

          node = %MDEx.HtmlInline{literal: span}
          {node, acc + 1}

        node, acc ->
          {node, acc}
      end)

    document
  end

  # Escape HTML entities to prevent XSS attacks
  defp escape_html(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end
end
