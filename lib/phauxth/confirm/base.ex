defmodule Phauxth.Confirm.Base do
  @moduledoc """
  Base module for handling user / contact confirmation.

  This is used by both the Phauxth.Confirm and Phauxth.Confirm.PassReset
  modules.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import Phauxth.Confirm.Report
      alias Phauxth.Token

      @key_source Phauxth.Utils.default_endpoint() |> IO.inspect

      @doc """
      Verify the confirmation key and get the user data from the database.

      ## Options

      There are two options for the verify function:

        * max_age - the maximum age of the token, in seconds
          * the default is 1200 seconds (20 minutes)
        * log_meta - additional custom metadata for Phauxth.Log
          * this should be a keyword list

      """
      def verify(params, user_context, opts \\ [])
      def verify(%{"key" => key}, user_context, opts) do
        max_age = Keyword.get(opts, :max_age, 1200)
        log_meta = Keyword.get(opts, :log_meta, [])
        get_user(@key_source, {key, max_age, user_context})
        |> report(log_meta, opts[:mode])
      end
      def verify(_, _, _), do: raise ArgumentError, "No key found in the params"

      def get_user(key_source, {key, max_age, user_context}) do
        with {:ok, params} <- Token.verify(key_source, key, max_age),
          do: user_context.get_by(params)
      end

      defoverridable [verify: 3, get_user: 2]
    end
  end
end
