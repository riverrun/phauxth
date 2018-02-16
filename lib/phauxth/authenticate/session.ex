defmodule Phauxth.Authenticate.Session do
  @moduledoc """
  """

  #@callback

  defmacro __using__(_) do
    quote do
      @behaviour Phauxth.Authenticate.Session

      use Phauxth.Authenticate.Base

      @impl Phauxth.Authenticate.Base
      def get_user(conn, {max_age, user_context, _}) do
        with {session_id, user_id} <- Phauxth.Session.get_session_data(conn),
             %{sessions: sessions} = user <- user_context.get(user_id),
             timestamp when is_integer(timestamp) <- sessions[session_id],
          do:
            (timestamp + max_age > System.system_time(:second) and user) ||
              {:error, "session expired"}
      end

      def get_user2(conn, {max_age, user_context, _}) do
        Phauxth.Session.get_session_data(conn)
        |> user_context.process_data()
        #|> check_timestamp
      end

      defoverridable Plug
      defoverridable Phauxth.Authenticate.Base
      #defoverridable Phauxth.Authenticate.Session
    end
  end
end
