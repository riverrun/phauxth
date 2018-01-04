defmodule Phauxth.Authenticate.UserData do
  @moduledoc """
  """

  @doc """
  """
  @callback get_user_data(conn :: Plug.Conn.t(), opts :: tuple, check_func :: function) ::
              map | {:error, String.t()} | nil
end
