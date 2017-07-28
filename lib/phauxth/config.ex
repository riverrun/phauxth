defmodule Phauxth.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.

  The following are valid configuration items.


  | name               | type          | default          |
  | :----------------- | :-----------  | ---------------: |
  | log_level          | atom          | :info            |
  | drop_user_keys     | list of atoms | []               |
  | token_salt         | string        | N/A              |

  ## Examples

  The simplest way to change the default values would be to add
  a `phauxth` entry to the `config.exs` file in your project,
  like the following example.

      config :phauxth,
        log_level: :warn,
        drop_user_keys: [:shoe_size]

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
  The salt to be used when creating and verifying tokens.
  """
  def token_salt do
    Application.get_env(:phauxth, :token_salt) || raise """
    You need to set the `token_salt` value in the config/config.exs file.
    To generate a suitable random salt, use the `gen_token_salt` function
    in the Phauxth.Config module.
    """
  end

  @doc """
  Generate a random salt for use with the api token.
  """
  def gen_token_salt(length \\ 8) do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end
end
