defmodule RaffleyWeb.RaffleLive.Index do
  alias RaffleyWeb.CustomComponents
  use RaffleyWeb, :live_view

  alias Raffley.Raffles
  import RaffleyWeb.CustomComponents

  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:raffles, Raffles.list_raffles())
      |> assign(:form, to_form(%{}))

    # IO.inspect(socket.assigns.streams.raffles, label: "MOUNT")

    # socket =
    #   attach_hook(socket, :log_stream, :after_render, fn socket ->
    #     IO.inspect(socket.assigns.streams.raffles, label: "AFTER RENDER")
    #     socket
    #   end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <.banner :if={false}>
        <.icon name="hero-sparkles-solid" /> Mystery Raffle Coming Soon!
        <:details :let={vibe}>
          To Be Revealed Tomorrow {vibe}
        </:details>
        <:details>
          Any guesses?
        </:details>
      </.banner>

      <.filter_form form={@form} />

      <div class="raffles" id="raffles" phx-update="stream">
        <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} id={dom_id} raffle={raffle} />
      </div>
    </div>
    """
  end

  def filter_form(assigns) do
    ~H"""
    <.form for={@form}>
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" />
      <.input
        type="select"
        field={@form[:status]}
        prompt="Status"
        options={[:upcoming, :open, :closed]}
      />
      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort By"
        options={[:prize, :ticket_price]}
      />
    </.form>
    """
  end

  attr :raffle, Raffley.Raffles.Raffle, required: true
  attr :id, :string, required: true

  def raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle}"} id={@id}>
      <div class="card">
        <img src={@raffle.image_path} />
        <h2>{@raffle.prize}</h2>
        <div class="details">
          <div class="price">
            ${@raffle.ticket_price} / ticket
          </div>
          <CustomComponents.badge status={@raffle.status} />
        </div>
      </div>
    </.link>
    """
  end
end
