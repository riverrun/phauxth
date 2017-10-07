defmodule Phauxth.Channel do
  @moduledoc """
  Functions for use with Phoenix channels.
  """

  import Plug.Conn
  alias Phauxth.{Log, Token}

  @doc """
  Add a token to the conn - for use with Phoenix channels.

  ## Options

  In addition to the token options (see the documentation for Phauxth.Token
  for details), there is one option:

    * token_data - the data to be encoded in the token
      * this needs to be a capture (see below for an example)
      * the default is `&%{"user_id" => &1.email})`, which translates to `%{"user_id" => user.email}`

  ## Examples

  In the pipeline you want to use:

      plug Phauxth.Authenticate
      plug Phauxth.Channel.put_token, token_data: &%{"user_id" => &1.username}

  The example above sets the token data to %{"user_id" => user.username}.

  To set the token data to just the username (not using a map):

      plug Phauxth.Channel.put_token, token_data: &(&1.username)

  """
  def put_token(%Plug.Conn{assigns: %{current_user: user}} = conn, opts)
      when is_map(user) do
    {token_data, log_meta, opts} =
      {Keyword.get(opts, :token_data, &%{"user_id" => &1.email}),
        Keyword.get(opts, :log_meta, []), opts}
    Log.info(%Log{user: user.id, message: "user token added", meta: log_meta})
    token = Token.sign(conn, token_data.(user), opts)
    assign(conn, :user_token, token)
  end
  def put_token(conn, _), do: conn
end
