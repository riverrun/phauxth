defmodule Phauxth.Authenticate.Remember do
  @moduledoc """
  Base module for remember me functionality.

  This is `use`-d by Phauxth.Remember, and it can also be used
  to produce a custom remember me module.
  """

  defmacro __using__(_) do
    quote do
      use Phauxth.Authenticate.Base

      alias Phauxth.Config

      @max_age 7 * 24 * 60 * 60

      @impl Plug
      def init(opts) do
        create_session_func =
          opts[:create_session_func] ||
            raise """
            Phauxth.Remember - you need to set a `create_session_func` in the opts
            """

        unless is_function(create_session_func, 1) do
          raise """
          Phauxth.Remember - the `create_session_func` should be a function
          that takes one argument
          """
        end

        opts =
          opts
          |> Keyword.put_new(:max_age, 14_400)
          |> Keyword.put_new(:token_module, Config.token_module())
          |> super()

        {create_session_func, opts}
      end

      @impl Plug
      def call(%Plug.Conn{assigns: %{current_user: %{}}} = conn, _), do: conn

      def call(%Plug.Conn{req_cookies: %{"remember_me" => _}} = conn, {create_session_func, opts}) do
        conn |> super(opts) |> add_session(create_session_func)
      end

      def call(conn, _), do: conn

      @impl Phauxth.Authenticate.Base
      def authenticate(%Plug.Conn{req_cookies: %{"remember_me" => token}}, user_context, opts) do
        token_module = opts[:token_module]

        with {:ok, user_id} <- token_module.verify(token, opts),
             do: get_user({:ok, %{"user_id" => user_id}}, user_context)
      end

      @impl Phauxth.Authenticate.Base
      def set_user(nil, conn), do: super(nil, delete_rem_cookie(conn))
      def set_user(user, conn), do: super(user, conn)

      defp add_session(%Plug.Conn{assigns: %{current_user: %{}}} = conn, create_session_func) do
        {:ok, %{id: session_id}} = create_session_func.(conn)

        conn
        |> put_session(:phauxth_session_id, session_id)
        |> configure_session(renew: true)
      end

      defp add_session(conn, _), do: conn

      defoverridable Phauxth.Authenticate.Base
    end
  end
end
