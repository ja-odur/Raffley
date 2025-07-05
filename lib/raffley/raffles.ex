defmodule Raffley.Raffles do
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo
  
  def list_raffles do
    Repo.all(Raffle)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def featured_raffles(%Raffle{} = raffle) do
    list_raffles() |> List.delete(raffle)
  end
end
