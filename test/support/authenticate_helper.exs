defmodule Phauxth.AbsintheAuthenticate do
  use Phauxth.Authenticate.Base
  import Plug.Conn

  def set_user(user, conn) do
    put_private(conn, :absinthe, %{token: %{current_user: user}})
  end
end

defmodule Phauxth.CustomSession do
  use Phauxth.Authenticate.Base
  import Plug.Conn

  def check_session(conn) do
    unless get_session(conn, :shoe_size) < 6 do
      get_session(conn, :user_id)
    end
  end

end

defmodule Phauxth.CustomToken do
  use Phauxth.Authenticate.Base
  import Plug.Conn

  def check_token(_conn, _token, _max_age) do
    {:ok, 3}
  end

end
