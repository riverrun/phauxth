defmodule <%= base %>Web.SessionView do
  use <%= base %>Web, :view<%= if api do %>

  def render("info.json", %{info: token}) do
    %{access_token: token}
  end<% end %>
end
