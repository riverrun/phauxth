defmodule Phauxth.Confirm do
  @moduledoc """
  Module to provide user confirmation for new users.

  ## Options

  There are three main options:

    * `:user_context` - the user_context module
      * this can also be set in the config
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list
    * `:max_age` - the maximum age for the token
      * the default is 720 seconds - 20 minutes

  The options keyword list is also passed to the token verify function.
  See the documentation for Phauxth.Token for information about defining
  and setting the token module.
  """

  use Phauxth.Confirm.Base

  @impl true
  def report({:ok, user}, meta) do
    if user.confirmed_at do
      Log.warn(%Log{user: user.id, message: "user already confirmed", meta: meta})
      {:error, Config.user_messages().already_confirmed()}
    else
      super({:ok, user}, meta)
    end
  end

  def report(result, meta), do: super(result, meta)
end
