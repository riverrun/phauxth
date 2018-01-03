defmodule Phauxth.AbsintheAuthenticate do
  use Phauxth.Authenticate.Base

  @impl true
  def set_user(user, conn) do
    put_private(conn, :absinthe, %{token: %{current_user: user}})
  end
end

defmodule Phauxth.CustomSession do
  use Phauxth.Authenticate.Base

  @impl true
  def get_user(conn, {:session, max_age, user_context, _}) do
    AuthBase.get_user_from_session(conn, &custom_check_session/1, {max_age, user_context})
  end

  def custom_check_session(conn) do
    with <<session_id::binary-size(25), user_id::binary>> <-
           get_session(conn, :phauxth_session_id),
         do: {session_id, user_id}
  end
end

defmodule Phauxth.CustomToken do
  use Phauxth.Authenticate.Base

  @impl true
  def get_user(conn, {:token, max_age, user_context, opts}) do
    AuthBase.get_user_from_token(conn, &custom_check_token/4, {max_age, user_context, opts})
  end

  def custom_check_token(_conn, _token, _max_age, _opts) do
    {:ok, 3}
  end
end
