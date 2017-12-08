defmodule Phauxth.Log do
  @moduledoc """
  Logging functions for Phauxth.

  ## Format

  Phauxth uses logfmt to provide a standard logging format.

    15:31:08.575 [warn] user=ray@example.com message="invalid password"

    * `:user` - the user identifier (one of email, username, nil)
    * `:message` - error / info message
    * `:meta` - additional metadata that does not fit into any of the other categories

  ## Log levels

  The available log levels are :info, :warn and false.

  The level at which logging starts can be configured by changing
  the `log_level` value in the config file.

  The default log_level is :info, but if you only want warnings printed
  out, add the following to the config file:

      config :phauxth,
        log_level: :warn

  And if you do not want Phauxth to print out any logs, set the
  log_level to false.
  """

  require Logger
  alias Phauxth.Config

  defstruct user: "nil", message: "", meta: []

  for level <- [:debug, :info, :warn, :error] do
    @doc """
    Returns the #{level} log message.
    """
    def unquote(level)(%Phauxth.Log{user: user, message: message, meta: meta}) do
      if Config.log_level() && Logger.compare_levels(unquote(level), Config.log_level()) != :lt do
        Logger.log(unquote(level), fn ->
          Enum.map_join([{"user", user}, {"message", message}] ++ meta, " ", &format/1)
        end)
      end
    end
  end

  @doc """
  Returns the id of the currently logged-in user, if present.
  """
  def current_user_id(%{current_user: %{id: id}}), do: "#{id}"
  def current_user_id(_), do: "nil"

  defp format({key, val}) when is_binary(val) do
    if String.contains?(val, [" ", "="]) or val == "" do
      ~s(#{key}="#{val}")
    else
      ~s(#{key}=#{val})
    end
  end

  defp format({key, val}), do: format({key, to_string(val)})
end
