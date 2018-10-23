ExUnit.start()

Code.require_file("support/access_control.exs", __DIR__)
Code.require_file("support/custom_authenticate.exs", __DIR__)
Code.require_file("support/custom_confirm.exs", __DIR__)
Code.require_file("support/custom_login.exs", __DIR__)
Code.require_file("support/session_helper.exs", __DIR__)
Code.require_file("support/user_helper.exs", __DIR__)

Application.put_env(:phauxth, :user_context, Phauxth.TestUsers)
Application.put_env(:phauxth, :crypto_module, Comeonin.Argon2)
Application.put_env(:argon2_elixir, :t_cost, 1)
Application.put_env(:argon2_elixir, :m_cost, 8)
Application.put_env(:phauxth, :endpoint, PhauxthWeb.Endpoint)
Application.put_env(:phauxth, :token_module, Phauxth.PhxToken)
Application.put_env(:phauxth, :token_salt, Phauxth.Config.gen_token_salt())

defmodule PhauxthWeb.Endpoint do
  def config(:secret_key_base), do: String.duplicate("abcdef0123456789", 8)
end
