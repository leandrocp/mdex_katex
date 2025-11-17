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
                // Hook is attached to the katex-block itself, not a container
                const latex = this.el.dataset.latex;
                if (latex) {
                  katex.render(latex, this.el, {
                    displayMode: true,
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
                const elements = this.el.querySelectorAll('.katex-block');
                elements.forEach(el => {
                  const latex = el.dataset.latex;
                  if (latex) {
                    // Clear previous content to avoid double-rendering
                    el.innerHTML = '';
                    katex.render(latex, el, {
                      displayMode: true,
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

  def mount(_params, _session, socket) do
    markdown = """
    # Physics Formulas

    ## Einstein's Mass-Energy Equivalence

    ```math
    E = mc^2
    ```

    ## Newton's Second Law

    ```math
    \\vec{F} = m\\vec{a}
    ```

    ## Schrödinger Equation

    ```math
    i\\hbar\\frac{\\partial}{\\partial t}\\Psi(\\vec{r},t) = \\hat{H}\\Psi(\\vec{r},t)
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
    """

    mdex =
      MDEx.new(markdown: markdown)
      |> MDExKatex.attach(
        katex_init: "",
        katex_block_attrs: fn seq ->
          ~s(id="katex-#{seq}" class="katex-block" phx-hook="KaTeXHook" phx-update="ignore")
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
      .katex-block {
        padding: 2rem;
        margin: 2rem 0;
        background: #f8fafc;
        border-left: 4px solid #3b82f6;
        border-radius: 0.5rem;
        overflow-x: auto;
      }
      h1 {
        font-size: 2.5rem;
        font-weight: 700;
        margin-bottom: 2rem;
        color: #1e293b;
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
    </style>

    <div class="min-h-screen bg-white">
      <nav class="bg-gray-800 text-white shadow-lg">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <div class="flex items-center">
              <div class="flex space-x-4">
                <.link patch="/physics" class="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700 transition">
                  Physics
                </.link>
                <.link patch="/calculus" class="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700 transition">
                  Calculus
                </.link>
              </div>
            </div>
          </div>
        </div>
      </nav>
      <div class="container mx-auto py-12 px-4 sm:px-6 lg:px-8 max-w-4xl">
        <%= @html %>
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
    example_1 = """
    # Calculus - Basic Formulas

    ## Fundamental Theorem of Calculus

    ```math
    \\int_a^b f'(x)\\,dx = f(b) - f(a)
    ```

    ## Integration by Parts

    ```math
    \\int u\\,dv = uv - \\int v\\,du
    ```

    ## Taylor Series

    ```math
    f(x) = \\sum_{n=0}^{\\infty} \\frac{f^{(n)}(a)}{n!}(x-a)^n
    ```

    ## Euler's Formula

    ```math
    e^{ix} = \\cos(x) + i\\sin(x)
    ```
    """

    MDEx.new(markdown: example_1)
    |> MDExKatex.attach(
      katex_init: "",
      katex_block_attrs: fn seq ->
        ~s(id="katex-#{seq}" class="katex-block" phx-update="ignore")
      end
    )
    |> MDEx.to_html!()
  end

  defp example_2 do
    example_2 = """
    # Calculus - Advanced Topics

    ## Multivariable Chain Rule

    ```math
    \\frac{\\partial f}{\\partial t} = \\frac{\\partial f}{\\partial x}\\frac{\\partial x}{\\partial t} + \\frac{\\partial f}{\\partial y}\\frac{\\partial y}{\\partial t}
    ```

    ## Divergence Theorem

    ```math
    \\iiint_V (\\nabla \\cdot \\vec{F})\\,dV = \\iint_S \\vec{F} \\cdot \\hat{n}\\,dS
    ```

    ## Green's Theorem

    ```math
    \\oint_C (L\\,dx + M\\,dy) = \\iint_D \\left(\\frac{\\partial M}{\\partial x} - \\frac{\\partial L}{\\partial y}\\right)\\,dA
    ```

    ## Laplace Transform

    ```math
    \\mathcal{L}\\{f(t)\\} = F(s) = \\int_0^{\\infty} e^{-st}f(t)\\,dt
    ```

    ## Fourier Transform

    ```math
    \\hat{f}(\\xi) = \\int_{-\\infty}^{\\infty} f(x)e^{-2\\pi ix\\xi}\\,dx
    ```
    """

    MDEx.new(markdown: example_2)
    |> MDExKatex.attach(
      katex_init: "",
      katex_block_attrs: fn seq ->
        ~s(id="katex-#{seq}" class="katex-block" phx-update="ignore")
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
      .katex-block {
        padding: 2rem;
        margin: 2rem 0;
        background: #f8fafc;
        border-left: 4px solid #3b82f6;
        border-radius: 0.5rem;
        overflow-x: auto;
      }
      h1 {
        font-size: 2.5rem;
        font-weight: 700;
        margin-bottom: 2rem;
        color: #1e293b;
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
    </style>

    <div id="calculus-demo" class="min-h-screen bg-white" phx-hook="KaTeXGlobalHook">
      <nav class="bg-gray-800 text-white shadow-lg">
        <div class="container mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between h-16">
            <div class="flex items-center">
              <div class="flex space-x-4">
                <.link patch="/physics" class="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700 transition">
                  Physics
                </.link>
                <.link patch="/calculus" class="px-3 py-2 rounded-md text-sm font-medium hover:bg-gray-700 transition">
                  Calculus
                </.link>
              </div>
            </div>
          </div>
        </div>
      </nav>
      <div class="container mx-auto py-12 px-4 sm:px-6 lg:px-8 max-w-4xl">
        <div class="mb-8 flex gap-4">
          <button
            phx-click="show_example_1"
            class={"px-6 py-3 rounded-lg font-medium transition-all " <> if @example_1, do: "bg-blue-500 text-white shadow-md", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"}>
            Basic Formulas
          </button>
          <button
            phx-click="show_example_2"
            class={"px-6 py-3 rounded-lg font-medium transition-all " <> if @example_2, do: "bg-blue-500 text-white shadow-md", else: "bg-gray-200 text-gray-700 hover:bg-gray-300"}>
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
    <body class="min-h-screen">
      <div class="container mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <h1 class="text-xl">Math Formula Demos</h1>

        <ul>
          <li><.link patch={"/physics"} class="text-blue-500">Physics Formulas</.link></li>
          <li><.link patch={"/calculus"} class="text-blue-500">Calculus</.link></li>
        </ul>
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
