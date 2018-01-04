defmodule Phauxth.Authenticate.Token do
  @moduledoc """
  """

  alias Phauxth.Token

  @behaviour Phauxth.Authenticate.UserData

  @impl true
  def get_user_data(
        %Plug.Conn{req_headers: headers} = conn,
        {max_age, user_context, opts},
        check_func \\ &verify_user/4
      ) do
    with {_, token} <- List.keyfind(headers, "authorization", 0),
         {:ok, user_id} <- check_func.(conn, token, max_age, opts),
         do: user_context.get(user_id)
  end

  @doc """
  Check the token for the current user.
  """
  def verify_user(conn, token, max_age, opts) do
    Token.verify(conn, token, max_age, opts)
  end
end
