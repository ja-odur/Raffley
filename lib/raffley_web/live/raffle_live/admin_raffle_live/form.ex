defmodule RaffleyWeb.AdminRaffleLive.Form do
  use RaffleyWeb, :live_view

  alias Raffley.Admin
  alias Raffley.Raffles.Raffle

  def mount(params, _session, socket) do
    {:ok, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    raffle = %Raffle{}
    changeset = Admin.change_raffle(raffle)

    socket
    |> assign(:page_title, "New Raffle")
    |> assign(:form, to_form(changeset))
    |> assign(:raffle, raffle)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    raffle = Admin.get_raffle!(id)
    changeset = Admin.change_raffle(raffle)

    socket
    |> assign(:page_title, "Edit Raffle")
    |> assign(:form, to_form(changeset))
    |> assign(:raffle, raffle)
  end

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>
    <.simple_form for={@form} id="raffle-form" phx-submit="save" phx-change="validate">
      <.input field={@form[:prize]} label="Prize" />
      <.input field={@form[:description]} type="textarea" label="Description" phx-debounce="blur" />
      <.input field={@form[:ticket_price]} type="number" label="Ticket Price" />
      <.input
        field={@form[:status]}
        type="select"
        label="Status"
        prompt="Choose a status"
        options={[:upcoming, :open, :closed]}
      />
      <.input field={@form[:image_path]} label="Image Path" />

      <:actions>
        <.button phx-disable-with="Saving...">Save Raffle</.button>
      </:actions>
    </.simple_form>

    <.back navigate={~p"/admin/raffles"}>
      Back
    </.back>
    """
  end

  def handle_event("validate", %{"raffle" => raffle_params}, socket) do
    changeset = Admin.change_raffle(socket.assigns.raffle, raffle_params)
    socket = assign(socket, :form, to_form(changeset, action: :validate))
    {:noreply, socket}
  end

  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    case Admin.create_raffle(raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle created successfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end
end
