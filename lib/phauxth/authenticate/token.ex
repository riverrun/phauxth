defmodule Phauxth.Authenticate.Token do
  @moduledoc """
  """

  @doc """
  Gets the token from the authorization headers.
  """
  @callback get_token_user(list, Plug.Conn.t(), tuple) :: map | nil

  defmacro __using__(_) do
    quote do
      @behaviour Phauxth.Authenticate.Token

      use Phauxth.Authenticate.Base

      @impl Phauxth.Authenticate.Base
      def get_user(conn, opts) do
        conn |> get_req_header("authorization") |> get_token_user(conn, opts)
      end

      @impl Phauxth.Authenticate.Token
      def get_token_user([], _, _), do: {:error, "no token found"}

      def get_token_user([token | _], conn, {max_age, user_context, opts}) do
        with {:ok, id} <- Phauxth.Token.verify(conn, token, max_age, opts),
        do: user_context.get(id)
      end

      defoverridable Plug
      defoverridable Phauxth.Authenticate.Base
      defoverridable Phauxth.Authenticate.Token
    end
  end
end
