defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.

  This module is used by Phauxth.Login, and it can also be used to
  create customized Plugs to handle login.

  ## Custom login

  The init/1, call/2 and check_pass/2 functions can all be overridden.

  ### Custom module for password authentication

  You can use a different module to handle password authentication by
  overriding the check_pass/2 function.

  ### Custom value for the hash name (in the database)

  Overriding the check_pass/2 function will also let you use a different
  value to refer to the password hash (:password_hash is the default).
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Plug

      import unquote(__MODULE__)
      import Phauxth.Login.Utils
      alias Comeonin.Bcrypt
      alias Phauxth.Config

      @doc false
      def init(opts) do
        uniq = Keyword.get(opts, :unique_id, :email)
        user_params = if is_atom(uniq), do: to_string(uniq), else: "email"
        {uniq, user_params}
      end

      @doc false
      def call(%Plug.Conn{params: %{"session" => params}} = conn,
          {uniq, user_params}) when is_atom(uniq) do
        %{^user_params => user_id, "password" => password} = params
        Config.repo.get_by(Config.user_mod, [{uniq, user_id}])
        |> check_pass(password)
        |> report(conn, user_id, "successful login")
      end
      def call(_conn, _), do: raise ArgumentError, "unique_id should be an atom"

      @doc false
      def check_pass(nil, _) do
        Bcrypt.dummy_checkpw
        {:error, "invalid user-identifier"}
      end
      def check_pass(%{password_hash: hash} = user, password) do
        Bcrypt.checkpw(password, hash) and
        {:ok, user} || {:error, "invalid password"}
      end

      defoverridable [init: 1, call: 2, check_pass: 2]
    end
  end
end
