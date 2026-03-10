Mix.install([
  {:phoenix_playground, "~> 0.1"},
  {:mdex_katex, path: ".."}
])

defmodule DemoLayout do
  use Phoenix.Component

  def render("root.html", assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en" class="h-full">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>mdex-katex</title>
      </head>
      <body>
        <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.css">
        <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16/dist/katex.min.js"></script>

        <script src="/assets/phoenix/phoenix.js"></script>
        <script src="/assets/phoenix_live_view/phoenix_live_view.js"></script>

        <script>
          let hooks = {
            KaTeXHook: {
              mounted() {
                // Hook is attached to the formula element itself, not a container
                const latex = this.el.dataset.latex;
                const mathStyle = this.el.dataset.mathStyle;
                if (latex && mathStyle) {
                  katex.render(latex, this.el, {
                    displayMode: mathStyle === "display",
                    throwOnError: false,
                    trust: true
                  });
                }
              }
            },

            KaTeXGlobalHook: {
              mounted() {
                this.renderKatex();
              },
              updated() {
                this.renderKatex();
              },
              renderKatex() {
                const elements = this.el.querySelectorAll('.katex-block, .katex-inline');
                elements.forEach(el => {
                  const latex = el.dataset.latex;
                  const mathStyle = el.dataset.mathStyle;
                  if (latex && mathStyle) {
                    // Clear previous content to avoid double-rendering
                    el.innerHTML = '';
                    katex.render(latex, el, {
                      displayMode: mathStyle === "display",
                      throwOnError: false,
                      trust: true
                    });
                  }
                });
              }
            },
          }

          let liveSocket =
            new window.LiveView.LiveSocket(
              "/live",
              window.Phoenix.Socket,
              { hooks }
            )
          liveSocket.connect()

          window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
            reloader.enableServerLogs()
            window.liveReloader = reloader
          })
        </script>

        <%= @inner_content %>
      </body>
    </html>
    """
  end
end

defmodule PhysicsLive do
  use Phoenix.LiveView

  defp shell_classes do
    "min-h-screen bg-slate-100 text-slate-900"
  end

  defp card_classes do
    "mx-auto max-w-5xl px-4 py-8 sm:px-6 lg:px-8"
  end

  def mount(_params, _session, socket) do
    markdown = ~S"""
    # Physics Formulas

    In text, energy and mass are related by $E = mc^2$, and force follows $\vec{F} = m\vec{a}$.

    ## Einstein's Mass-Energy Equivalence

    ```math
    E = mc^2
    ```

    ## Newton's Second Law

    ```math
    \vec{F} = m\vec{a}
    ```

    ## Schrödinger Equation

    ```math
    i\hbar\frac{\partial}{\partial t}\Psi(\vec{r},t) = \hat{H}\Psi(\vec{r},t)
    ```

    ## Maxwell's Equations

    Gauss's Law:

    ```math
    \nabla \cdot \vec{E} = \frac{\rho}{\epsilon_0}
    ```

    Faraday's Law:

    ```math
    \nabla \times \vec{E} = -\frac{\partial \vec{B}}{\partial t}
    ```
    """

    mdex =
      MDEx.new(markdown: markdown, extension: [math_dollars: true])
      |> MDExKatex.attach(
        katex_init: "",
        katex_block_attrs: fn seq ->
          ~s(id="katex-#{seq}" class="katex-block" phx-hook="KaTeXHook" phx-update="ignore")
        end,
        katex_inline_attrs: fn seq ->
          ~s(id="katex-inline-#{seq}" class="katex-inline" phx-hook="KaTeXHook" phx-update="ignore")
        end
      )

    html = MDEx.to_html!(mdex)
    {:ok, assign(socket, html: {:safe, html})}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <style>
      :root {
        --demo-bg: linear-gradient(180deg, #f8fbff 0%, #f4f7fb 100%);
        --demo-surface: rgba(255, 255, 255, 0.92);
        --demo-border: rgba(148, 163, 184, 0.22);
        --demo-text: #142033;
        --demo-muted: #526074;
        --demo-accent: #1d4ed8;
        --demo-accent-soft: rgba(29, 78, 216, 0.1);
      }
      .demo-shell {
        background: radial-gradient(circle at top, rgba(125, 211, 252, 0.22), transparent 30%), var(--demo-bg);
      }
      .demo-nav {
        border-bottom: 1px solid rgba(148, 163, 184, 0.18);
        background: rgba(15, 23, 42, 0.92);
        backdrop-filter: blur(10px);
      }
      .demo-panel {
        background: var(--demo-surface);
        border: 1px solid var(--demo-border);
        border-radius: 24px;
        box-shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
        padding: 2rem;
        font-family: "Iowan Old Style", "Palatino Linotype", "Book Antiqua", Georgia, serif;
        line-height: 1.7;
      }
      .demo-eyebrow {
        display: inline-block;
        margin-bottom: 1rem;
        padding: 0.4rem 0.75rem;
        border-radius: 999px;
        background: var(--demo-accent-soft);
        color: var(--demo-accent);
        font: 600 0.72rem/1.1 system-ui, -apple-system, sans-serif;
        letter-spacing: 0.14em;
        text-transform: uppercase;
      }
      .katex-block {
        padding: 1.4rem 1.5rem;
        margin: 1.4rem 0 1.8rem;
        background: linear-gradient(180deg, #f8fbff 0%, #f2f6fb 100%);
        border: 1px solid rgba(96, 165, 250, 0.22);
        border-left: 4px solid var(--demo-accent);
        border-radius: 16px;
        overflow-x: auto;
      }
      .katex-inline {
        padding: 0 0.18rem;
        color: var(--demo-accent);
      }
      h1 {
        font-size: clamp(2.2rem, 4vw, 3rem);
        font-weight: 700;
        margin: 0 0 1rem;
        line-height: 1.1;
        letter-spacing: -0.03em;
        color: var(--demo-text);
      }
      h2 {
        font-size: 1.35rem;
        font-weight: 600;
        margin-top: 2.4rem;
        margin-bottom: 0.8rem;
        color: var(--demo-text);
      }
      p {
        margin: 1rem 0;
        color: var(--demo-muted);
      }
      @media (max-width: 640px) {
        .demo-panel {
          padding: 1.2rem;
          border-radius: 18px;
        }
      }
    </style>

    <div class={"demo-shell " <> shell_classes()}>
      <nav class="demo-nav text-white shadow-lg">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <div class="flex items-center">
              <div class="flex space-x-4">
                <.link patch="/physics" class="rounded-full px-4 py-2 text-sm font-medium text-slate-100 transition hover:bg-white/10">
                  Physics
                </.link>
                <.link patch="/calculus" class="rounded-full px-4 py-2 text-sm font-medium text-slate-100 transition hover:bg-white/10">
                  Calculus
                </.link>
              </div>
            </div>
          </div>
        </div>
      </nav>
      <div class={card_classes()}>
        <div class="demo-panel">
          <div class="demo-eyebrow">MDEx + KaTeX</div>
          <%= @html %>
        </div>
      </div>
    </div>
    """
  end
end

defmodule CalculusLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    socket
    |> assign(:example_1, true)
    |> assign(:example_2, false)
    |> assign(:html, {:safe, example_1()})
    |> then(&{:ok, &1})
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  defp example_1 do
    example_1 = ~S"""
    # Calculus - Basic Formulas

    In text, the derivative of $x^2$ is $2x$.

    ## Fundamental Theorem of Calculus

    ```math
    \int_a^b f'(x)\,dx = f(b) - f(a)
    ```

    ## Integration by Parts

    ```math
    \int u\,dv = uv - \int v\,du
    ```

    ## Taylor Series

    ```math
    f(x) = \sum_{n=0}^{\infty} \frac{f^{(n)}(a)}{n!}(x-a)^n
    ```

    ## Euler's Formula

    ```math
    e^{ix} = \cos(x) + i\sin(x)
    ```
    """

    MDEx.new(markdown: example_1, extension: [math_dollars: true])
    |> MDExKatex.attach(
      katex_init: "",
      katex_block_attrs: fn seq ->
        ~s(id="katex-#{seq}" class="katex-block" phx-update="ignore")
      end,
      katex_inline_attrs: fn seq ->
        ~s(id="katex-inline-#{seq}" class="katex-inline" phx-update="ignore")
      end
    )
    |> MDEx.to_html!()
  end

  defp example_2 do
    example_2 = ~S"""
    # Calculus - Advanced Topics

    In text, the Laplace variable $s$ and Fourier variable $\xi$ show up throughout analysis.

    ## Multivariable Chain Rule

    ```math
    \frac{\partial f}{\partial t} = \frac{\partial f}{\partial x}\frac{\partial x}{\partial t} + \frac{\partial f}{\partial y}\frac{\partial y}{\partial t}
    ```

    ## Divergence Theorem

    ```math
    \iiint_V (\nabla \cdot \vec{F})\,dV = \iint_S \vec{F} \cdot \hat{n}\,dS
    ```

    ## Green's Theorem

    ```math
    \oint_C (L\,dx + M\,dy) = \iint_D \left(\frac{\partial M}{\partial x} - \frac{\partial L}{\partial y}\right)\,dA
    ```

    ## Laplace Transform

    ```math
    \mathcal{L}\{f(t)\} = F(s) = \int_0^{\infty} e^{-st}f(t)\,dt
    ```

    ## Fourier Transform

    ```math
    \hat{f}(\xi) = \int_{-\infty}^{\infty} f(x)e^{-2\pi ix\xi}\,dx
    ```
    """

    MDEx.new(markdown: example_2, extension: [math_dollars: true])
    |> MDExKatex.attach(
      katex_init: "",
      katex_block_attrs: fn seq ->
        ~s(id="katex-#{seq}" class="katex-block" phx-update="ignore")
      end,
      katex_inline_attrs: fn seq ->
        ~s(id="katex-inline-#{seq}" class="katex-inline" phx-update="ignore")
      end
    )
    |> MDEx.to_html!()
  end

  def handle_event("show_example_1", _params, socket) do
    socket
    |> assign(:example_1, true)
    |> assign(:example_2, false)
    |> assign(:html, {:safe, example_1()})
    |> then(&{:noreply, &1})
  end

  def handle_event("show_example_2", _params, socket) do
    socket
    |> assign(:example_1, false)
    |> assign(:example_2, true)
    |> assign(:html, {:safe, example_2()})
    |> then(&{:noreply, &1})
  end

  def render(assigns) do
    ~H"""
    <style>
      :root {
        --demo-bg: linear-gradient(180deg, #f8fbff 0%, #f4f7fb 100%);
        --demo-surface: rgba(255, 255, 255, 0.92);
        --demo-border: rgba(148, 163, 184, 0.22);
        --demo-text: #142033;
        --demo-muted: #526074;
        --demo-accent: #1d4ed8;
        --demo-accent-soft: rgba(29, 78, 216, 0.1);
      }
      .demo-shell {
        background: radial-gradient(circle at top, rgba(125, 211, 252, 0.22), transparent 30%), var(--demo-bg);
      }
      .demo-nav {
        border-bottom: 1px solid rgba(148, 163, 184, 0.18);
        background: rgba(15, 23, 42, 0.92);
        backdrop-filter: blur(10px);
      }
      .demo-panel {
        background: var(--demo-surface);
        border: 1px solid var(--demo-border);
        border-radius: 24px;
        box-shadow: 0 24px 60px rgba(15, 23, 42, 0.08);
        padding: 2rem;
        font-family: "Iowan Old Style", "Palatino Linotype", "Book Antiqua", Georgia, serif;
        line-height: 1.7;
      }
      .demo-eyebrow {
        display: inline-block;
        margin-bottom: 1rem;
        padding: 0.4rem 0.75rem;
        border-radius: 999px;
        background: var(--demo-accent-soft);
        color: var(--demo-accent);
        font: 600 0.72rem/1.1 system-ui, -apple-system, sans-serif;
        letter-spacing: 0.14em;
        text-transform: uppercase;
      }
      .katex-block {
        padding: 1.4rem 1.5rem;
        margin: 1.4rem 0 1.8rem;
        background: linear-gradient(180deg, #f8fbff 0%, #f2f6fb 100%);
        border: 1px solid rgba(96, 165, 250, 0.22);
        border-left: 4px solid var(--demo-accent);
        border-radius: 16px;
        overflow-x: auto;
      }
      .katex-inline {
        padding: 0 0.18rem;
        color: var(--demo-accent);
      }
      h1 {
        font-size: clamp(2.2rem, 4vw, 3rem);
        font-weight: 700;
        margin: 0 0 1rem;
        line-height: 1.1;
        letter-spacing: -0.03em;
        color: var(--demo-text);
      }
      h2 {
        font-size: 1.35rem;
        font-weight: 600;
        margin-top: 2.4rem;
        margin-bottom: 0.8rem;
        color: var(--demo-text);
      }
      p {
        margin: 1rem 0;
        color: var(--demo-muted);
      }
      @media (max-width: 640px) {
        .demo-panel {
          padding: 1.2rem;
          border-radius: 18px;
        }
      }
    </style>

    <div id="calculus-demo" class="demo-shell min-h-screen bg-white" phx-hook="KaTeXGlobalHook">
      <nav class="demo-nav text-white shadow-lg">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <div class="flex items-center">
              <div class="flex space-x-4">
                <.link patch="/physics" class="rounded-full px-4 py-2 text-sm font-medium text-slate-100 transition hover:bg-white/10">
                  Physics
                </.link>
                <.link patch="/calculus" class="rounded-full px-4 py-2 text-sm font-medium text-slate-100 transition hover:bg-white/10">
                  Calculus
                </.link>
              </div>
            </div>
          </div>
        </div>
      </nav>
      <div class="container mx-auto py-12 px-4 sm:px-6 lg:px-8 max-w-4xl">
        <div class="demo-panel">
          <div class="demo-eyebrow">MDEx + KaTeX</div>
          <div class="mb-8 flex flex-wrap gap-3 rounded-full bg-slate-100 p-2 w-fit">
            <button
              phx-click="show_example_1"
              class={"rounded-full px-5 py-2.5 text-sm font-medium transition-all " <> if @example_1, do: "bg-white text-slate-900 shadow-sm", else: "text-slate-600 hover:text-slate-900"}>
              Basic Formulas
            </button>
            <button
              phx-click="show_example_2"
              class={"rounded-full px-5 py-2.5 text-sm font-medium transition-all " <> if @example_2, do: "bg-white text-slate-900 shadow-sm", else: "text-slate-600 hover:text-slate-900"}>
              Advanced Topics
            </button>
          </div>

          <div :if={@example_1}>
            <%= @html %>
          </div>

          <div :if={@example_2}>
            <%= @html %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end

defmodule DemoLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <body class="min-h-screen bg-slate-100 text-slate-900">
      <div class="mx-auto flex min-h-screen max-w-4xl items-center px-4 py-12 sm:px-6 lg:px-8">
        <div class="w-full rounded-[28px] border border-slate-200 bg-white/90 p-8 shadow-[0_24px_60px_rgba(15,23,42,0.08)] backdrop-blur">
          <p class="inline-block rounded-full bg-blue-50 px-3 py-1 text-sm font-medium uppercase tracking-[0.18em] text-blue-700">MDEx + KaTeX</p>
          <h1 class="mt-4 text-4xl font-semibold tracking-tight text-slate-900">Math Formula Demos</h1>
          <p class="mt-4 max-w-2xl text-base leading-7 text-slate-600">
            Small demo pages showing inline and display formulas in static and LiveView-style rendering.
          </p>

          <div class="mt-8 grid gap-4 sm:grid-cols-2">
            <.link patch={"/physics"} class="rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 transition hover:border-slate-300 hover:bg-white">
              <span class="block text-lg font-medium text-slate-900">Physics Formulas</span>
              <span class="mt-1 block text-sm text-slate-600">Inline relationships and larger display equations.</span>
            </.link>
            <.link patch={"/calculus"} class="rounded-2xl border border-slate-200 bg-slate-50 px-5 py-4 transition hover:border-slate-300 hover:bg-white">
              <span class="block text-lg font-medium text-slate-900">Calculus</span>
              <span class="mt-1 block text-sm text-slate-600">Toggle between basic and advanced formula sets.</span>
            </.link>
          </div>
        </div>
      </div>
    </body>
    """
  end
end

defmodule DemoRouter do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:put_root_layout, html: {DemoLayout, :root})
    plug(:put_secure_browser_headers)
  end

  scope "/" do
    pipe_through(:browser)
    live("/", DemoLive)
    live("/physics", PhysicsLive)
    live("/calculus", CalculusLive)
  end
end

PhoenixPlayground.start(plug: DemoRouter, open_browser: true)
