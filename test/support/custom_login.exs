defmodule Phauxth.CustomLogin do
  use Phauxth.Login.Base

  @impl true
  def authenticate(%{"password" => password} = params, user_context, opts) do
    case user_context.get_by(params) do
      nil -> {:error, "no user found"}
      %{confirmed_at: nil} -> {:error, "account unconfirmed"}
      user -> Phauxth.Login.check_pass(user, password, opts)
    end
  end
end
