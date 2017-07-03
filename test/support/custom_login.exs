defmodule Phauxth.CustomHashname do

  use Phauxth.Login.Base

  def check_pass(nil, _, _, _), do: {:error, "invalid user-identifier"}
  def check_pass(%{encrypted_password: hash} = user, password, crypto, opts) do
    crypto.verify_hash(hash, password, opts) and
    {:ok, user} || {:error, "invalid password"}
  end

end
