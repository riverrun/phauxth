defmodule Phauxth.CustomConfirm do
  use Phauxth.Confirm.Base

  @impl true
  def verify(%{"key" => key}, user_context, opts) do
    get_user(opts[:conn], {key, 600, user_context, opts})
    |> report([])
  end

  @impl true
  def get_user(key_source, {key, max_age, user_context, opts}) do
    with {:ok, params} <- Token.verify(key_source, key, max_age, opts) do
      user = user_context.get_by(params)
      %{user | confirmed_at: nil}
    end
  end

  @impl true
  def report(%{} = user, meta) do
    check_user_confirmed(user, meta)
  end

  def report(result, meta), do: super(result, meta)
end
