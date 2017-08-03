defmodule <%= base %>Web.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use <%= base %>Web, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(<%= base %>Web.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(<%= base %>Web.ErrorView, :"404")
  end

  def call(conn, nil) do
    IO.puts "Hello!"
    conn
    |> put_status(:unauthorized)
    |> render(<%= base %>Web.ErrorView, :"401")
  end
end
