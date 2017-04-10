defmodule Phauxth.SessionHelper do
  @moduledoc """
  Session helper for testing purposes.
  """

  use Plug.Test

  @secret String.duplicate("abcdef0123456789", 8)
  @default_opts [store: :cookie, key: "spameggs", signing_salt: "signing salt", log: false]
  @signing_opts Plug.Session.init(@default_opts)

  def sign_conn(conn, secret \\ @secret) do
    put_in(conn.secret_key_base, secret)
    |> Plug.Session.call(@signing_opts)
    |> fetch_session
  end

end
