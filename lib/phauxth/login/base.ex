defmodule Phauxth.Login.Base do
  @moduledoc """
  Base module for handling login.

  This is used by Phauxth.Login and can also be used to create
  custom login modules.

  ## Custom login modules

  One example of a custom login module is shown below:

      defmodule MyApp.LoginConfirm do
        use Phauxth.Login.Base

        def validate(%{"password" => password} = params, opts) do
          case Config.user_context().get_by(params) do
            nil -> {:error, "no user found"}
            %{confirmed_at: nil} -> {:error, "account unconfirmed"}
            user -> Config.crypto_module().check_pass(user, password, opts)
          end
        end
      end

  In this example, the `validate` function is overridden to check
  the user struct to see if the user is confirmed. If the user has not
  been confirmed, an error is returned. Otherwise, the default validate
  function is run.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import Plug.Conn
      alias Phauxth.{Config, Log}

      @behaviour Phauxth

      @impl true
      def verify(params, opts \\ [])

      def verify(%{"password" => _password} = params, opts) do
        log_meta = Keyword.get(opts, :log_meta, [])
        params |> validate(opts) |> report(log_meta)
      end

      def verify(_, _), do: raise(ArgumentError, "No password found in the params")

      @impl true
      def validate(%{"password" => password} = params, opts) do
        case Config.user_context().get_by(params) do
          nil -> {:error, "no user found"}
          user -> Config.crypto_module().check_pass(user, password, opts)
        end
      end

      @impl true
      def report({:ok, user}, meta) do
        Log.info(%Log{user: user.id, message: "successful login", meta: meta})
        {:ok, Map.drop(user, Config.drop_user_keys())}
      end

      def report({:error, message}, meta) do
        Log.warn(%Log{message: message, meta: meta})
        {:error, Config.user_messages().default_error()}
      end

      defoverridable Phauxth
    end
  end
end
