defmodule Raffley.Raffles do
  alias Raffley.Charities.Charity
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo
  import Ecto.Query

  def list_raffles do
    Repo.all(Raffle)
  end

  def filter_raffles(filter) do
    Raffle
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> with_charity(filter["charity"])
    |> sort(filter["sort_by"])
    |> preload(:charity)
    |> Repo.all()
  end

  defp with_charity(query, slug) when slug in ["", nil], do: query

  defp with_charity(query, slug) do
    # from r in query,
    #   join: c in Charity,
    #   on: r.charity_id == c.id,
    #   where: c.slug == ^slug

    from r in query,
      join: c in assoc(r, :charity),
      where: c.slug == ^slug
  end

  defp with_status(query, status) when status in ~w(open closed upcoming) do
    query |> where(status: ^status)
  end

  defp with_status(query, _status), do: query

  defp search_by(query, q) when q in ["", nil], do: query

  defp search_by(query, q) do
    query |> where([r], ilike(r.prize, ^"%#{q}%"))
  end

  defp sort(query, "prize") do
    query |> order_by(:prize)
  end

  defp sort(query, "ticket_price_desc") do
    query |> order_by(desc: :ticket_price)
  end

  defp sort(query, "ticket_price_asc") do
    query |> order_by(asc: :ticket_price)
  end

  defp sort(query, "charity") do
    from r in query,
      join: c in assoc(r, :charity),
      order_by: c.name
  end

  defp sort(query, _sort_by) do
    query |> order_by(:id)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
    |> Repo.preload(:charity)
  end

  def featured_raffles(%Raffle{} = raffle) do
    # Simulate two second deplay to test async loading
    # on the UI
    Process.sleep(2000)

    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
