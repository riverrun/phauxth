defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user confirmation.

  This is used by Phauxth.Confirm and Phauxth.Confirm.PassReset,
  and it can also be used to create custom user confirmation modules.
  """

  @doc """
  Gets the user data from the database.
  """
  @callback get_user({:ok, map} | {:error, String.t() | atom}, module) ::
              {:ok, map} | {:error, String.t() | atom}

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Phauxth
      @behaviour Phauxth.Confirm.Base

      alias Phauxth.{Config, Log}

      @impl Phauxth
      def verify(params, opts \\ [])

      def verify(%{"key" => token} = params, opts) do
        user_context = Keyword.get(opts, :user_context, Config.user_context())
        log_meta = Keyword.get(opts, :log_meta, [])
        opts = Keyword.put_new(opts, :token_module, Config.token_module())
        params |> authenticate(user_context, opts) |> report(log_meta)
      end

      def verify(_, _), do: raise(ArgumentError, "No key found in the params")

      @impl Phauxth
      def authenticate(%{"key" => token}, user_context, opts) do
        token_module = opts[:token_module]

        token
        |> token_module.verify(opts ++ [max_age: 1200])
        |> get_user(user_context)
      end

      @impl Phauxth.Confirm.Base
      def get_user({:ok, data}, user_context) do
        case user_context.get_by(data) do
          nil -> {:error, "no user found"}
          user -> {:ok, user}
        end
      end

      def get_user({:error, message}, _), do: {:error, message}

      @impl Phauxth
      def report({:ok, user}, meta) do
        Log.info(%Log{user: user.id, message: "user confirmed", meta: meta})
        {:ok, Map.drop(user, Config.drop_user_keys())}
      end

      def report({:error, message}, meta) do
        Log.warn(%Log{message: message, meta: meta})
        {:error, Config.user_messages().default_error()}
      end

      defoverridable Phauxth
      defoverridable Phauxth.Confirm.Base
    end
  end
end
