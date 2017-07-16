defmodule Phauxth.CustomLogin do
  @moduledoc """
  Custom login module for testing purposes.
  """

  use Phauxth.Login.Base

  def check_pass(nil, _, _) do
    {:error, "Invalid credentials"}
  end
  def check_pass(_, _, _) do
    {:ok, %{email: "frank@mail.com"}}
  end

end

defmodule Phauxth.Argon2Login do
  @moduledoc """
  Login module using Argon2 for testing purposes.
  """

  use Phauxth.Login.Base

  defdelegate check_pass(user, password, opts), to: Comeonin.Argon2
end
