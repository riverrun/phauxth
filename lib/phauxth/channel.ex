defmodule Phauxth.Channel do
  @moduledoc """
  Plug to add a token to the conn for use with Phoenix channels.

  This Plug adds a token, with an identifier for the current user,
  to the conn. This needs to be called after Phauxth.Authenticate
  in the pipeline you are using in the `router.ex` file.

  ## Options

  In addition to the token options (see the documentation for Phauxth.Token
  for details), there is one option:

    * token_id - the data to be encoded in the token
      * this needs to be an atom
      * the default is :email, which is then translated to `%{"user_id" => user.email}`

  ## Examples

  In the pipeline you want to use:

      plug Phauxth.Authenticate
      plug Phauxth.Channel, token_id: :username

  In the above example, a token is generated with %{"user_id" => user.username}
  as data.
  """

  import Plug.Conn
  alias Phauxth.{Log, Token}

  @behaviour Plug

  @doc false
  def init(opts) do
    {Keyword.get(opts, :token_id, :email),
      Keyword.get(opts, :log_meta, []), opts}
  end

  @doc false
  def call(%Plug.Conn{assigns: %{current_user: user}} = conn,
           {token_id, log_meta, opts}) when is_map(user) do
    Log.info(%Log{user: user.id, message: "user token added", meta: log_meta})
    token = Token.sign(conn, %{"user_id" => user[token_id]}, opts)
    assign(conn, :user_token, token)
  end
  def call(conn, _), do: conn
end
