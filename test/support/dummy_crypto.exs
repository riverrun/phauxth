defmodule Phauxth.DummyCrypto do
  @moduledoc """
  A dummy crypto module for testing purposes.
  """

  def hash_pwd_salt(password, _opts) do
    "dumb-#{password}-crypto"
  end

  def no_user_verify(_opts) do
    false
  end

  def verify_hash(hash, password, opts) do
    hash == hash_pwd_salt(password, opts)
  end
end
