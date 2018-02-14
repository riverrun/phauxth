defmodule Phauxth.AbsintheAuthenticate do
  use Phauxth.Authenticate.Token

  @impl true
  def set_user(user, conn) do
    put_private(conn, :absinthe, %{context: %{current_user: user}})
  end
end
