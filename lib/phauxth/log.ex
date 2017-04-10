defmodule Phauxth.Log do
  @moduledoc """
  Logging functions for Phauxth.

  ## Format

  Phauxth uses logfmt to provide a standard logging format.

    15:31:08.575 [warn] path=/session/create user=ray@mail.com message=invalid password

    * path - the request path
    * user - the user identifier (one of email, username, nil)
    * message - error / info message
    * meta - additional metadata that does not fit into any of the other categories
  """

  require Logger

  defstruct user: "nil", message: "", meta: []

  @doc """
  Returns the log message.

  The level at which logging starts can be configured by changing
  the `log_level` value in the config file.

  The default log_level is :info, but if you only want warnings printed
  out, add the following to the config file:

      config :phauxth,
        log_level: :warn

  And if you do not want Phauxth to print out any logs, set the
  log_level to false.
  """
  def log(_, false, _, _), do: :ok
  def log(level, log_level, path, %Phauxth.Log{user: user, message: message, meta: meta}) do
    if Logger.compare_levels(level, log_level) != :lt do
      Logger.log level, fn ->
        Enum.map_join([{"path", path}, {"user", user}, {"message", message}] ++
                      meta, " ", &format/1)
      end
    end
    :ok
  end

  @doc """
  Returns the id of the currently logged-in user, if present.
  """
  def current_user_id(%{current_user: %{id: id}}), do: "#{id}"
  def current_user_id(_), do: "nil"

  defp format({key, val}) when is_binary(val) do
    if String.contains?(val, [" ", "="]) do
      ~s(#{key}="#{val}")
    else
      ~s(#{key}=#{val})
    end
  end
  defp format({key, val}), do: format({key, to_string(val)})
end
