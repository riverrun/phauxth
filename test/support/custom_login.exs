defmodule Phauxth.CustomLogin do
  @moduledoc """
  Custom login module for testing purposes.
  """

  use Phauxth.Login.Base

  def check_pass(nil, _, _, _) do
    {:error, "invalid credentials"}
  end
  def check_pass(_, _, _, _) do
    {:ok, %{id: 6, email: "frank@mail.com"}}
  end

end
