defmodule Phauxth.CustomConfirm do
  use Phauxth.Confirm.Base

  # change this example into something more useful
  @impl true
  def verify(%{"key" => key}, user_context, opts) do
    token_mod = Phauxth.PhxToken
    get_user(token_mod, {key, user_context, opts})
    |> report([])
  end

  @impl true
  def get_user(token_mod, {key, user_context, opts}) do
    with {:ok, params} <- token_mod.verify(key, opts) do
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
