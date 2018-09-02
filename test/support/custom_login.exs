defmodule Phauxth.CustomLogin do
  use Phauxth.Login.Base

  alias Phauxth.Config

  def verify(%{"pass" => password} = params, opts) do
    user_context = Keyword.get(opts, :user_context, Config.user_context())

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
