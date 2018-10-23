defmodule Phauxth.CustomLogin do
  use Phauxth.Login.Base

  def validate(%{"password" => password} = params, opts) do
    case Config.user_context().get_by(params) do
      nil -> {:error, "no user found"}
      %{confirmed_at: nil} -> {:error, "account unconfirmed"}
      user -> Config.crypto_module().check_pass(user, password, opts)
    end
  end
end
