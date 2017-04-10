defmodule Phauxth.Authenticate.Base do
  @moduledoc """
  Authenticate the current user, using Plug sessions or Phoenix token.

  ## Example using Phoenix

  Add the following line to the pipeline in the `web/router.ex` file:

      plug Phauxth.Authenticate

  To use with an api, add a context:

      plug Phauxth.Authenticate, context: MyApp.Web.Endpoint

  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import Plug.Conn
      import unquote(__MODULE__)
      import Phauxth.Authenticate.Utils

      @doc false
      def init(opts) do
        {Keyword.get(opts, :context),
        Keyword.get(opts, :max_age, 24 * 60 * 60)}
      end

      @doc false
      def call(conn, {nil, _}) do
        check_session(conn) |> set_current_user(conn)
      end
      def call(%Plug.Conn{req_headers: headers} = conn, {context, max_age}) do
        check_headers(headers, context, max_age) |> set_current_user(conn)
      end
      def call(conn, _), do: assign(conn, :current_user, nil)

      defoverridable [init: 1, call: 2]
    end
  end
end
