defmodule Phauxth.Config do
  @moduledoc """
  This module provides an abstraction layer for configuration.

  The following are valid configuration items.


  | name               | type          | default          |
  | :----------------- | :-----------  | ---------------: |
  | repo               | module        | N/A              |
  | user_mod           | module        | N/A              |
  | log_level          | atom          | :info            |
  | drop_user_keys     | list of atoms | []               |

  ## Required values

  The `repo` and `user_mod` values have to be set to use Phauxth.

  ## Examples

  The simplest way to change the default values would be to add
  an `phauxth` entry to the `config.exs` file in your project,
  like the following example.

      config :phauxth,
        repo: MyApp.Repo,
        user_mod: MyApp.Accounts.User,
        drop_user_keys: [:shoe_size]

  """

  @doc """
  The repository module.
  """
  def repo do
    Application.get_env(:phauxth, :repo)
  end

  @doc """
  The user model module.
  """
  def user_mod do
    Application.get_env(:phauxth, :user_mod)
  end

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

  By default, :password_hash and :password are removed, and this option allows you to add to this list.
  """
  def drop_user_keys do
    Application.get_env(:phauxth, :drop_user_keys, []) ++
    [:password_hash, :password, :otp_secret]
  end
end
