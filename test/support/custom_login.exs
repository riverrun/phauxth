defmodule Phauxth.CustomLogin do
  use Phauxth.Login.Base

  def authenticate(%{"password" => password} = params, user_context, opts) do
    case user_context.get_by(params) do
      nil -> {:error, "no user found"}
      %{confirmed_at: nil} -> {:error, "account unconfirmed"}
      user -> Config.crypto_module().check_pass(user, password, opts)
    end
  end
end
