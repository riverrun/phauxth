defmodule <%= base %>Web.Plugs.CheckRole do
	import Plug.Conn

	def init(default), do: default

	def call(conn, default) do
		<%= base %>Web.Authorize.role_check(conn, default)
	end

end

