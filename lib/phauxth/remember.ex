defmodule Phauxth.Remember do
  @moduledoc """
  Remember me Plug.

  ## Options

  There are two options:

    * max_age - the length of the validity of the token
      * the default is two weeks
    * user_context - the user context module to be used
      * the default is MyApp.Accounts

  ## Examples

  Add the following line to the pipeline you want to authenticate in
  the `web/router.ex` file:

      plug Phauxth.Authenticate
      plug Phauxth.Remember

  Make sure you add the Phauxth.Remember Plug after Phauxth.Authenticate.
  """

  use Phauxth.Authenticate.Base
  import Plug.Conn
  alias Phauxth.Token

  @max_age 14 * 24 * 60 * 60

  def init(opts) do
    {Keyword.get(opts, :max_age, @max_age),
    Keyword.get(opts, :user_context, default_user_context())}
  end

  def call(%Plug.Conn{req_cookies: %{"remember_me" => token}} = conn, opts) do
    if conn.assigns[:current_user] do
      conn
    else
      get_user(conn, token, opts) |> log_user |> set_user(conn)
    end
  end
  def call(conn, _), do: conn

  def get_user(conn, token, {max_age, user_context}) do
    with {:ok, user_id} <- check_token(token, {conn, max_age}),
      do: user_context.get(user_id)
  end

  @doc """
  Add a token as a remember me cookie.
  """
  def add_rem_cookie(conn, user_id, max_age \\ @max_age) do
    cookie = Token.sign(conn, user_id)
    put_resp_cookie(conn, "remember_me", cookie, [http_only: true, max_age: max_age])
  end

  @doc """
  Delete the remember_me cookie.
  """
  def delete_rem_cookie(conn) do
    register_before_send(conn, &delete_resp_cookie(&1, "remember_me"))
  end

end
