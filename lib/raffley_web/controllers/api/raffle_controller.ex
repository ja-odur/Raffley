defmodule RaffleyWeb.Api.RaffleController do
  use RaffleyWeb, :controller

  alias Raffley.Admin

  def index(conn, _params) do
    raffles = Admin.list_raffles()

    render(conn, :index, raffles: raffles)
  end

  def show(conn, %{"id" => id}) do
    raffle = Admin.get_raffle!(id)
    
    render(conn, :show, raffle: raffle)
  end
end
