defmodule Phauxth.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.

  The following are valid configuration items.


  | name               | type          | default          |
  | :----------------- | :-----------  | ---------------: |
  | log_level          | atom          | :info            |
  | drop_user_keys     | list of atoms | []               |
  | endpoint           | module        | N/A              |
  | token_salt         | string        | N/A              |

  ## Umbrella apps

  A namespaced app name is required in the `apps/my_app_name/config/config.exs` file
  when Phauxth is used in an Umbrella project, where multiple apps
  are using the library.

  This because in Umbrella projects the children apps configurations
  are merged together and the conflicting keys overridden,
  so we need to namespace every Phauxth configuration to avoid the override
  and to be able to retrieving the correct peculiar values for each child application.

  ## Examples

  With a regular app, add a `phauxth` entry to the `config.exs`
  file in your project, as in the following example.

      config :phauxth,
        token_salt: "YkLmt7+f",
        endpoint: MyAppWeb.Endpoint,
        log_level: :warn,
        drop_user_keys: [:shoe_size]

  Here is an example of a namespaced entry (part of an umbrella app):

      config :phauxth_my_app_name,
        token_salt: "YkLmt7+f",
        endpoint: MyAppName.Endpoint
  """

  @doc """
  The log level for Phauxth logs.

  This should either be an atom, :debug, :info, :warn or :error, or
  false.

  The default is :info, which means that :info, :warn and :error logs
  will be returned.
  """
  def log_level do
    Application.get_env(:phauxth, :log_level, :info)
  end

  @doc """
  The keys that are removed from the user struct before it is passed
  on to another function.

  This should be a list of atoms.

  By default, :password_hash, :password and :otp_secret are removed,
  and this option allows you to add to this list.
  """
  def drop_user_keys do
    Application.get_env(:phauxth, :drop_user_keys, []) ++
    [:password_hash, :password, :otp_secret]
  end

  @doc """
  The endpoint of your app.

  This is used by the Phauxth.Confirm module.
  """
  def endpoint do
    Application.get_env(:phauxth, :endpoint)
    || Application.get_env(namespaced_phauxth(), :endpoint)
    || raise """
    You need to set the `endpoint` value in the config/config.exs file.
    """
  end

  @doc """
  The salt to be used when creating and verifying tokens.

  This is used by the Phauxth.Authenticate module, if you are using
  token authentication, and by the Phauxth.Confirm module.
  """
  def token_salt do
    Application.get_env(:phauxth, :token_salt)
    || Application.get_env(namespaced_phauxth(), :token_salt)
    || raise """
    You need to set the `token_salt` value in the config/config.exs file.

    To generate a suitable random salt, use the `gen_token_salt` function
    in the Phauxth.Config module.
    """
  end

  @doc """
  Generate a random salt for use with token authentication.
  """
  def gen_token_salt(length \\ 8)
  def gen_token_salt(length) when length > 7 do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end
  def gen_token_salt(_) do
    raise ArgumentError, """
    The length is too short. The token_salt should be at least 8 characters long.
    """
  end

  defp namespaced_phauxth do
    #current_app =  Mix.Project.get.project[:app]
    current_app =  Mix.Project.config[:app]
    String.to_atom("phauxth_#{current_app}")
  end
end
