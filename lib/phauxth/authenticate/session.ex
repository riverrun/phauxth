defmodule Phauxth.Authenticate.Session do
  @moduledoc """
  """

  import Plug.Conn

  @behaviour Phauxth.Authenticate.UserData

  @impl true
  def get_user_data(conn, {max_age, user_context, _}, check_func \\ &verify_user/1) do
    with {session_id, user_id} <- check_func.(conn),
         %{sessions: sessions} = user <- user_context.get(user_id),
         timestamp when is_integer(timestamp) <- sessions[session_id],
         do:
           (timestamp + max_age > System.system_time(:second) and user) ||
             {:error, "session expired"}
  end

  @doc """
  Check the session for the current user.
  """
  def verify_user(conn) do
    with <<session_id::binary-size(17), user_id::binary>> <-
           get_session(conn, :phauxth_session_id),
         do: {session_id, user_id}
  end
end
