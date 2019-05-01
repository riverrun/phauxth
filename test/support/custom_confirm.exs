defmodule Phauxth.CustomConfirm do
  use Phauxth.Confirm.Base
end

defmodule Phauxth.CustomGetUserConfirm do
  use Phauxth.Confirm.Base

  @impl true
  def get_user({:ok, %{"email" => email} = data}, user_context) do
    case user_context.get_by(data) do
      nil -> {:error, "no user found"}
      user -> {:ok, Map.put(user, :current_email, email)}
    end
  end

  def get_user({:error, message}, _), do: {:error, message}
end
