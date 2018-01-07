defmodule Phauxth.SessionTest do
  use ExUnit.Case
  use Plug.Test

  alias Phauxth.{Authenticate, Session, SessionHelper, TestAccounts}

  defp call(id) do
    SessionHelper.add_session(id)
    |> Authenticate.call({:session, {4 * 60 * 60, TestAccounts, []}, []})
  end

  test "add_session adds phauxth_session_id to conn" do
    session_id =
      conn(:get, "/")
      |> Phauxth.SessionHelper.sign_conn()
      |> assign(:current_user, %{id: 2})
      |> Session.add_session(Session.gen_session_id("F"), 2)
      |> get_session(:phauxth_session_id)

    <<"F", _session_id::binary-size(16), user_id::binary>> = session_id
    assert user_id == "2"
  end

  test "fresh_session? can determine if session is fresh or not" do
    conn = call("F25/1mZuBno+Pfu061")
    assert Session.fresh_session?(conn) == true
    conn = call("S25/1mZuBno+Pfu061")
    assert Session.fresh_session?(conn) == false
    conn = call(nil)
    assert Session.fresh_session?(conn) == false
  end
end
