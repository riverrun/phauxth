defmodule <%= base %>Web.AuthCase do
  use Phoenix.ConnTest<%= if confirm do %>

  import Ecto.Changeset
  alias <%= base %>.{Accounts, Repo}<% else %>

  alias <%= base %>.Accounts<% end %>

  def add_user(email) do
    user = %{email: email, password: "mangoes&g0oseberries"}
    {:ok, user} = Accounts.create_user(user)
    user
  end<%= if confirm do %>

  def add_user_confirmed(email) do
    add_user(email)
    |> change(%{confirmed_at: DateTime.utc_now})
    |> Repo.update!
  end<% end %>

  def add_token_conn(conn, user) do
    user_token = Phauxth.Token.sign(<%= base %>Web.Endpoint, user.id)
    conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", user_token)
  end
end
