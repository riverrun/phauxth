defmodule Phauxth.CustomConfirm do
  use Phauxth.Confirm.Base

  def verify(%{"key" => key}, user_context, opts) do
    get_user(opts[:conn], {key, 600, user_context})
    |> report(opts[:mode], [])
  end

  def get_user(key_source, {key, max_age, user_context}) do
    with {:ok, params} <- Token.verify(key_source, key, max_age) do
      user = user_context.get_by(params)
      %{user | confirmed_at: nil}
    end
  end
end
