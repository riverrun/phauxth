defmodule Phauxth.Login do
  @moduledoc """
  Module to login users.

  Before using this module, you will need to add the `crypto_module` value
  to the config. The `crypto_module` must implement the Comeonin behaviour.

  ## Options

  There are two options:

    * `:user_context` - the user_context module
      * this can also be set in the config
    * `:log_meta` - additional custom metadata for Phauxth.Log
      * this should be a keyword list

  There are also options for verifying the password. See the documentation
  for the `check_pass` function for details.
  """

  use Phauxth.Login.Base

  alias Phauxth.Config

  @doc """
  Checks the password, using the crypto_module's `verify_pass/2`, by comparing
  the hash with the password hash found in a user struct, or map.

  This is a convenience function that takes a user struct, or map, as input
  and seamlessly handles the cases where no user is found.

  ## Options

    * `:hash_key` - the password hash identifier
      * this does not need to be set if the key is `:password_hash` or `:encrypted_password`
    * `:hide_user` - run the `no_user_verify/1` function if no user is found
      * the default is true
  """
  def check_pass(user, password, opts \\ [])

  def check_pass(nil, _password, opts) do
    unless opts[:hide_user] == false, do: Config.crypto_module().no_user_verify(opts)
    {:error, "invalid user-identifier"}
  end

  def check_pass(user, password, opts) when is_binary(password) do
    case get_hash(user, opts[:hash_key]) do
      {:ok, hash} ->
        if Config.crypto_module().verify_pass(password, hash) do
          {:ok, user}
        else
          {:error, "invalid password"}
        end

      _ ->
        {:error, "no password hash found in the user struct"}
    end
  end

  def check_pass(_, _, _) do
    {:error, "password is not a string"}
  end

  defp get_hash(%{password_hash: hash}, nil), do: {:ok, hash}
  defp get_hash(%{encrypted_password: hash}, nil), do: {:ok, hash}
  defp get_hash(_, nil), do: nil

  defp get_hash(user, hash_key) do
    if hash = Map.get(user, hash_key), do: {:ok, hash}
  end
end
