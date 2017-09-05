defmodule <%= base %>Web.Plugs.CheckUser do
	import Plug.Conn

	def init(default), do: default

	def call(conn, default) do
		<%= base %>Web.Authorize.user_check(conn, default)
	end

end

