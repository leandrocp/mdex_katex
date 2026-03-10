# MDExKatex Usage Rules

MDExKatex is a plugin for [MDEx](https://hex.pm/packages/mdex) that enables rendering [KaTeX](https://katex.org) mathematical formulas from markdown code blocks.

**Key Facts:**
- Supports both `math` and `katex` code fences
- Supports dollar math when `MDEx` enables `extension: [math_dollars: true]`
- Generates display `<div>` elements and inline `<span>` elements with `data-latex` attributes
- Requires KaTeX CSS and JavaScript for rendering
- Works with static HTML and Phoenix LiveView
- Client-side rendering via JavaScript
- Two LiveView hook patterns: individual and global

**Document Structure:**
- **When to Use**: Use cases and scenarios
- **Examples**: Links to working examples
- **Core API**: Basic usage and function signature
- **Common Patterns**: Static HTML, LiveView integration, custom attributes
- **Best Practices**: Security, error handling, unique IDs
- **Common Anti-Patterns**: What NOT to do (critical for avoiding bugs)
- **Pipeline Order**: Correct plugin usage
- **Code Block Detection**: Supported fence types
- **LaTeX Syntax**: Common formulas and commands
- **Reference**: Links to examples and documentation

## When to Use

Use MDExKatex when you need to:
- Render mathematical formulas and equations from markdown content
- Support LaTeX math notation in your markdown documents
- Integrate mathematical expressions into Phoenix LiveView applications
- Convert markdown with math code blocks to HTML with rendered formulas

## Examples

See the [examples directory](https://github.com/leandrocp/mdex_katex/tree/main/examples) for complete working examples:
- **static.exs**: Static HTML generation with styled output
- **live_view.exs**: Phoenix LiveView with both individual and global hook patterns

## Core API

### Basic Usage

The main function is `MDExKatex.attach/2` which attaches the plugin to an MDEx document:

````elixir
markdown = """
In text, Euler's identity is $e^{i\\pi} + 1 = 0$.

```math
E = mc^2
```
"""

mdex =
  MDEx.new(markdown: markdown, extension: [math_dollars: true])
  |> MDExKatex.attach()

html = MDEx.to_html!(mdex)
````

Both `math` and `katex` code fences are supported:

````elixir
markdown = """
```math
E = mc^2
```

```katex
F = ma
```
"""
````

Inline and display examples:

````markdown
Inline math: $e^{i\pi} + 1 = 0$

```math
E = mc^2
```
````

### Function Signature

```elixir
MDExKatex.attach(document, options \\ []) :: MDEx.Document.t()
```

**Options:**
- `:katex_init` - HTML to initialize KaTeX (default: auto-inject CDN script and CSS)
- `:katex_block_attrs` - Function to generate display math tag attributes
- `:katex_inline_attrs` - Function to generate inline math tag attributes

## Common Patterns

### Static HTML Documents

For simple static documents, the default configuration works out of the box:

```elixir
html = MDEx.new(markdown: markdown)
|> MDExKatex.attach()
|> MDEx.to_html!()
```

This injects the default initialization script (including CSS and JavaScript) and renders both display and inline math.

**For standalone HTML files**, wrap the output in a proper HTML5 document structure:

```elixir
body_content = MDEx.new(markdown: markdown) |> MDExKatex.attach() |> MDEx.to_html!()

html = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Math Formulas</title>
</head>
<body>
#{body_content}
</body>
</html>
"""

File.write!("output.html", html)
```

### Custom Block Attributes

The `:katex_block_attrs` option takes a function that receives a sequence number and returns an attribute string:

```elixir
block_attrs = fn seq ->
  ~s(id="formula-#{seq}" class="katex-block custom-class")
end

MDEx.new(markdown: markdown)
|> MDExKatex.attach(katex_block_attrs: block_attrs)
|> MDEx.to_html!()
```

**IMPORTANT:** Always include unique IDs in custom block attributes. The sequence number ensures uniqueness.

### Custom Inline Attributes

Inline dollar math uses `:katex_inline_attrs` so inline formulas can avoid block-level classes and styling:

```elixir
inline_attrs = fn seq ->
  ~s(id="inline-#{seq}" class="katex-inline custom-inline")
end

MDEx.new(markdown: "Euler wrote $e^{i\\pi} + 1 = 0$", extension: [math_dollars: true])
|> MDExKatex.attach(katex_inline_attrs: inline_attrs)
|> MDEx.to_html!()
```

### Phoenix LiveView Integration

For LiveView apps, disable auto-initialization since you'll manage KaTeX in your JS:

```elixir
# In your LiveView
def render(assigns) do
  ~H"""
  <div><%= {:safe, @html} %></div>
  """
end

def mount(_params, _session, socket) do
  html =
    MDEx.new(markdown: markdown)
    |> MDExKatex.attach(
      katex_init: "",  # Don't inject init script
      katex_block_attrs: fn seq ->
        ~s(id="katex-#{seq}" class="katex-block" phx-hook="KaTeXHook" phx-update="ignore")
      end,
      katex_inline_attrs: fn seq ->
        ~s(id="katex-inline-#{seq}" class="katex-inline" phx-hook="KaTeXHook" phx-update="ignore")
      end
    )
    |> MDEx.to_html!()

  {:ok, assign(socket, html: html)}
end
```

**Important:** There are TWO different LiveView hook patterns - choose based on your needs.

#### Pattern 1: Individual Hook (Hook on Each Formula Element)

When using `phx-hook="KaTeXHook"` on each formula element, the hook operates on `this.el` directly:

```javascript
// assets/js/app.js
import katex from 'katex';
import 'katex/dist/katex.min.css';

let hooks = {
  KaTeXHook: {
    mounted() {
      // Hook is attached to the formula element itself
      const latex = this.el.dataset.latex;
      const mathStyle = this.el.dataset.mathStyle;
      if (latex && mathStyle) {
        katex.render(latex, this.el, {
          displayMode: mathStyle === 'display',
          throwOnError: false,
          trust: true
        });
      }
    }
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: hooks
})
```

#### Pattern 2: Global Hook (Hook on Parent Container)

When using `phx-hook="KaTeXGlobalHook"` on a parent container, find all math children:

```elixir
# Elixir - no phx-hook on individual blocks
html = MDEx.new(markdown: markdown)
  |> MDExKatex.attach(
    katex_init: "",
    katex_block_attrs: fn seq ->
      ~s(id="katex-#{seq}" class="katex-block" phx-update="ignore")
    end
  )
  |> MDEx.to_html!()

# Template - hook on parent container
~H"""
<div id="content" phx-hook="KaTeXGlobalHook">
  <%= {:safe, @html} %>
</div>
"""
```

```javascript
let hooks = {
  KaTeXGlobalHook: {
    mounted() {
      this.renderKatex();
    },
    updated() {
      this.renderKatex();
    },
    renderKatex() {
      // Hook is on parent, find all children
      const elements = this.el.querySelectorAll('.katex-block, .katex-inline');
      elements.forEach(el => {
        const latex = el.dataset.latex;
        const mathStyle = el.dataset.mathStyle;
        if (latex && mathStyle) {
          el.innerHTML = '';  // Clear previous render
          katex.render(latex, el, {
            displayMode: mathStyle === 'display',
            throwOnError: false,
            trust: true
          });
        }
      });
    }
  }
}
```

**When to use which pattern:**
- **Individual hooks**: Better for static content, each formula manages itself
- **Global hook**: Better for dynamic content that changes, handles updates properly

### DOMContentLoaded Pattern

For pages that require waiting for DOM ready:

```elixir
@katex_init """
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll('.katex-block, .katex-inline').forEach(el => {
      const latex = el.dataset.latex;
      const mathStyle = el.dataset.mathStyle;
      if (latex && mathStyle) {
        katex.render(latex, el, {
          displayMode: mathStyle === 'display',
          throwOnError: false,
          trust: true
        });
      }
    });
  });
</script>
"""

MDEx.new(markdown: markdown)
|> MDExKatex.attach(katex_init: @katex_init)
|> MDEx.to_html!()
```

### KaTeX Options

The default rendering uses these KaTeX options:

```javascript
{
  displayMode: true,        // Per-element, based on data-math-style
  throwOnError: false,      // Render errors as text instead of throwing
  trust: true,              // Allow \url, \includegraphics, etc.
  output: 'htmlAndMathml'   // Generate both HTML and MathML for accessibility
}
```

For custom options, override `:katex_init` with your own configuration.

## Best Practices

### Always Use Unique IDs

Each math block must have a unique ID for proper rendering:

```elixir
# GOOD - uses sequence number for uniqueness
fn seq -> ~s(id="katex-#{seq}" class="katex-block") end

# BAD - all formulas have same ID
fn _seq -> ~s(id="katex" class="katex-block") end
```

### Include phx-update="ignore" in LiveView

Always use `phx-update="ignore"` to prevent LiveView from re-rendering formulas:

```elixir
fn seq -> ~s(id="katex-#{seq}" class="katex-block" phx-update="ignore") end

fn seq -> ~s(id="katex-inline-#{seq}" class="katex-inline" phx-update="ignore") end
```

### Style Display and Inline Math Separately

Display math often needs block spacing, while inline math should stay unobtrusive:

```css
.katex-block {
  padding: 1rem;
  margin: 1rem 0;
  background: #f5f5f5;
}

.katex-inline {
  padding: 0;
  margin: 0;
  background: transparent;
}
```

### CSS is Required

Unlike Mermaid, KaTeX requires its CSS stylesheet to be loaded. The default `:katex_init` includes it:

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
```

**Never skip the CSS** - formulas will not render correctly without it.

### Security Considerations

#### HTML Escaping

MDExKatex automatically escapes HTML entities in LaTeX content to prevent XSS attacks:

```elixir
# Input: <script>alert('xss')</script>
# Output: &lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;
```

#### Trust Option

The `trust` option controls access to potentially risky LaTeX commands:

```javascript
// Permissive (default) - allows \url, \includegraphics, etc.
katex.render(latex, el, { trust: true })

// Strict - disallows risky commands
katex.render(latex, el, { trust: false })
```

**Use `trust: false` for untrusted user content.**

#### Other Security Options

```javascript
{
  maxSize: 10,           // Prevent excessively large formulas
  maxExpand: 1000,       // Limit macro expansions
  strict: 'warn'         // LaTeX compliance strictness
}
```

### Error Handling

With `throwOnError: false` (default), invalid LaTeX is rendered as text with error styling:

```javascript
// Invalid LaTeX is shown with error color
katex.render('\\invalid', el, {
  throwOnError: false,
  errorColor: '#cc0000'
})
```

## Common Anti-Patterns

### DON'T: Duplicate initialization

```elixir
# BAD - KaTeX initialized both in layout AND via plugin
MDEx.new(markdown: markdown)
|> MDExKatex.attach()  # Injects init script
|> MDEx.to_html!()
# ... and also <script> in layout
```

**Instead:** Choose one initialization method - either let the plugin handle it or manage it yourself with `katex_init: ""`.

### DON'T: Forget the CSS

```html
<!-- BAD - missing CSS -->
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>
```

**Instead:** Always include the CSS stylesheet:
```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
<script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>
```

### DON'T: Forget sequence numbers in custom attrs

```elixir
# BAD - ignores sequence number
fn _seq -> ~s(id="katex-1" class="katex-block") end
```

**Instead:** Always use the sequence parameter:
```elixir
fn seq -> ~s(id="katex-#{seq}" class="katex-block") end
```

### DON'T: Render without checking for data-latex and data-math-style

```javascript
// BAD - doesn't check required data attributes
document.querySelectorAll('.katex-block, .katex-inline').forEach(el => {
  katex.render(el.dataset.latex, el);  // May be undefined or use wrong mode
});
```

**Instead:** Always check for the attribute:
```javascript
document.querySelectorAll('.katex-block, .katex-inline').forEach(el => {
  const latex = el.dataset.latex;
  const mathStyle = el.dataset.mathStyle;
  if (latex && mathStyle) {
    katex.render(latex, el, {
      ...options,
      displayMode: mathStyle === 'display'
    });
  }
});
```

### DON'T: Forget phx-update="ignore"

```elixir
# BAD - LiveView will re-render and break formulas
fn seq -> ~s(id="katex-#{seq}" class="katex-block" phx-hook="KaTeXHook") end
```

**Instead:**
```elixir
fn seq -> ~s(id="katex-#{seq}" class="katex-block" phx-hook="KaTeXHook" phx-update="ignore") end
```

### DON'T: Use individual hook pattern with querySelectorAll

```javascript
// BAD - Hook is on the formula element itself, not a container
KaTeXHook: {
  mounted() {
    const elements = this.el.querySelectorAll('.katex-block, .katex-inline');  // Won't find anything!
    elements.forEach(el => {
      katex.render(el.dataset.latex, el);
    });
  }
}
```

**Instead:** Operate on `this.el` directly for individual hooks:
```javascript
// GOOD - Hook is on each block
KaTeXHook: {
  mounted() {
    const latex = this.el.dataset.latex;
    const mathStyle = this.el.dataset.mathStyle;
    if (latex && mathStyle) {
      katex.render(latex, this.el, {
        ...options,
        displayMode: mathStyle === 'display'
      });
    }
  }
}
```

**Or use global hook pattern** if you need to find children:
```javascript
// GOOD - Hook is on parent container
KaTeXGlobalHook: {
  mounted() {
    const elements = this.el.querySelectorAll('.katex-block, .katex-inline');
    elements.forEach(el => {
      const latex = el.dataset.latex;
      const mathStyle = el.dataset.mathStyle;
      if (latex && mathStyle) {
        el.innerHTML = '';  // Clear first for dynamic content
        katex.render(latex, el, {
          ...options,
          displayMode: mathStyle === 'display'
        });
      }
    });
  }
}
```

### DON'T: Call attach() after to_html()

```elixir
# BAD - attach must be called before to_html
html = MDEx.to_html!(mdex)
mdex = MDExKatex.attach(mdex)  # Too late!
```

**Instead:** Build the pipeline in order:
```elixir
MDEx.new(markdown: markdown)
|> MDExKatex.attach()
|> MDEx.to_html!()
```

## Pipeline Order

MDExKatex uses MDEx's plugin system. The correct order is:

1. Create MDEx document: `MDEx.new/1`
2. Attach plugins: `MDExKatex.attach/2`
3. Convert to HTML: `MDEx.to_html!/1`

```elixir
MDEx.new(markdown: markdown)
|> MDExKatex.attach(options)
|> MDEx.to_html!()
```

## Code Block Detection

MDExKatex processes code blocks tagged as **either `math` or `katex`**:

````markdown
```math
E = mc^2
```

```katex
F = ma
```
````

Both fence types work identically. Other code blocks (e.g., `elixir`, `python`) are left untouched.

## LaTeX Syntax

KaTeX supports most LaTeX math commands. Common examples:

### Basic Formulas

```latex
E = mc^2                           # Superscripts
x_i                                # Subscripts
\frac{a}{b}                        # Fractions
\sqrt{x}                           # Square root
\int_a^b f(x) dx                   # Integrals
\sum_{i=1}^{n} i                   # Summation
```

### Greek Letters

```latex
\alpha, \beta, \gamma, \Delta, \pi, \Omega
```

### Special Symbols

```latex
\infty                             # Infinity
\partial                           # Partial derivative
\nabla                             # Nabla/Del operator
\vec{v}                            # Vector
\hat{x}                            # Hat
```

### Aligned Equations

```latex
\begin{aligned}
f(x) &= x^2 \\
g(x) &= \sqrt{x}
\end{aligned}
```

See [KaTeX documentation](https://katex.org/docs/supported.html) for full list of supported commands.

## Reference

For complete working examples, see:
- [Static HTML example](https://github.com/leandrocp/mdex_katex/blob/main/examples/static.exs)
- [LiveView example with both hook patterns](https://github.com/leandrocp/mdex_katex/blob/main/examples/live_view.exs)
- [Full API documentation](https://hexdocs.pm/mdex_katex/MDExKatex.html#attach/2)
