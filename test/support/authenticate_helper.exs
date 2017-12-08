defmodule Phauxth.AbsintheAuthenticate do
  use Phauxth.Authenticate.Base

  def set_user(user, conn) do
    put_private(conn, :absinthe, %{token: %{current_user: user}})
  end
end

defmodule Phauxth.CustomSession do
  use Phauxth.Authenticate.Base

  def check_session(conn) do
    with <<session_id::binary-size(25), user_id::binary>> <-
           get_session(conn, :phauxth_session_id),
         do: {session_id, user_id}
  end
end

defmodule Phauxth.CustomToken do
  use Phauxth.Authenticate.Base

  def check_token(_conn, _token, _max_age, _opts) do
    {:ok, 3}
  end
end
