defmodule Phauxth.CustomCrypto do

  use Phauxth.Login.Base

  alias Phauxth.DummyCrypto

  def check_pass(nil, _), do: {:error, "invalid user-identifier"}
  def check_pass(%{password_hash: hash} = user, password) do
    DummyCrypto.checkpw(password, hash) and
    {:ok, user} || {:error, "invalid password"}
  end

end

defmodule Phauxth.CustomHashname do

  use Phauxth.Login.Base

  alias Phauxth.DummyCrypto

  def check_pass(nil, _), do: {:error, "invalid user-identifier"}
  def check_pass(%{encrypted_password: hash} = user, password) do
    DummyCrypto.checkpw(password, hash) and
    {:ok, user} || {:error, "invalid password", "Oh no you don't"}
  end

end
