defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user confirmation.

  This is used by Phauxth.Confirm and Phauxth.Confirm.PassReset,
  and it can also be used to create custom user confirmation modules.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Phauxth

      alias Phauxth.{Config, Log}

      @impl true
      def verify(params, opts \\ [])

      def verify(%{"key" => token} = params, opts) do
        user_context = Keyword.get(opts, :user_context, Config.user_context())
        log_meta = Keyword.get(opts, :log_meta, [])
        params |> authenticate(user_context, opts) |> report(log_meta)
      end

      def verify(_, _), do: raise(ArgumentError, "No key found in the params")

      @impl true
      def authenticate(%{"key" => token}, user_context, opts) do
        token
        |> Config.token_module().verify(opts ++ [max_age: 1200])
        |> get_user(user_context)
      end

      defp get_user({:ok, data}, user_context) do
        case user_context.get_by(data) do
          nil -> {:error, "no user found"}
          user -> {:ok, user}
        end
      end

      defp get_user({:error, message}, _), do: {:error, message}

      @impl true
      def report({:ok, user}, meta) do
        Log.info(%Log{user: user.id, message: "user confirmed", meta: meta})
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
