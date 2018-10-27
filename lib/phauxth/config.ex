defmodule Phauxth.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.

  The following are valid configuration items.


  | name               | type          | default          |
  | :----------------- | :-----------  | ---------------: |
  | user_context       | module        | N/A              |
  | log_level          | atom          | :info            |
  | token_module       | module        | N/A              |
  | crypto_module      | module        | N/A              |
  | user_messages      | module        | Phauxth.UserMessages |
  | drop_user_keys     | list of atoms | []               |

  ## Umbrella apps


  ## Examples

  Add a `phauxth` entry to the `config.exs` file in your project,
  as in the following example.

      config :phauxth,
        user_context: MyApp.Users,
        log_level: :warn,
        drop_user_keys: [:secret_key]

  """

  @doc """
  The users module to be used when querying the database.

  This module needs to have a `get_by(attrs)` function defined, which
  is used to fetch the relevant data.
  """
  def user_context do
    Application.get_env(:phauxth, :user_context)
  end

  @doc """
  The log level for Phauxth logs.

  This can be `false`, `:debug`, `:info`, `:warn` or `:error`.

  The default is `:info`, which means that `:info`, `:warn` and `:error` logs
  will be returned.
  """
  def log_level do
    Application.get_env(:phauxth, :log_level, :info)
  end

  @doc """
  The module used to sign and verify tokens.

  This module must implement the Phauxth.Token behaviour.
  See the documentation for Phauxth.Token for more information.
  """
  def token_module do
    Application.get_env(:phauxth, :token_module)
  end

  @doc """
  The module used to verify passwords.

  This is used by the Phauxth.Login module.
  """
  def crypto_module do
    Application.get_env(:phauxth, :crypto_module)
  end

  @doc """
  Module to be used to display messages to users.

  The default is Phauxth.UserMessages. See the documentation for
  Phauxth.UserMessages.Base for details about customizing / translating
  these messages.
  """
  def user_messages do
    Application.get_env(:phauxth, :user_messages, Phauxth.UserMessages)
  end

  @doc """
  The keys that are removed from the user struct before it is passed
  on to another function.

  This should be a list of atoms.

  By default, :password_hash, :encrypted_password, :password and
  :otp_secret are removed, and this option allows you to add to this list.
  """
  def drop_user_keys do
    remove_keys = [:password_hash, :encrypted_password, :password, :otp_secret]
    Application.get_env(:phauxth, :drop_user_keys, []) ++ remove_keys
  end

  @doc """
  Generates a random salt for use with token authentication.
  """
  def gen_token_salt(length \\ 8)

  def gen_token_salt(length) when length > 7 do
    :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)
  end

  def gen_token_salt(_) do
    raise ArgumentError, """
    The length is too short. The token salt should be at least 8 characters long.
    """
  end
end
