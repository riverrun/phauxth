defmodule Phauxth.CustomLogin do
  use Phauxth.Login.Base

  def verify(%{"pass" => password} = params, user_context, opts) do
    user_context.get_by(params)
    |> check_pass(password, Comeonin.Bcrypt, opts)
    |> report("Hi, how's it going?", [])
  end

  def check_pass(%{password_hash: "$argon2" <> _} = user, password, _crypto, opts) do
    Comeonin.Argon2.check_pass(user, password, opts)
  end
  def check_pass(user, password, crypto, opts) do
    crypto.check_pass(user, password, opts)
  end
end
