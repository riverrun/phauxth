defmodule <%= base %>Web.AuthCase do
  use Phoenix.ConnTest<%= if confirm do %>

  import Ecto.Changeset
  alias <%= base %>.{Accounts, Repo}<% else %>

  alias <%= base %>.Accounts<% end %>

  def add_user(email) do
    user = %{email: email, password: "mangoes&g0oseberries"}<%= if confirm do %>
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    {:ok, user} = Accounts.create_user(user, key)<% else %>
    {:ok, user} = Accounts.create_user(user)<% end %>
    user
  end<%= if confirm do %>

  def add_user_confirmed(email) do
    add_user(email)
    |> change(%{confirmed_at: DateTime.utc_now})
    |> Repo.update!
  end

  def add_reset(email) do
    add_user(email)
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    {:ok, user} = Accounts.add_reset_token(%{"email" => email}, key)
    user
  end<% end %>

  def add_token_conn(conn, user) do
    user_token = Phoenix.Token.sign(<%= base %>Web.Endpoint, "user auth", user.id)
    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", user_token)
  end
end
