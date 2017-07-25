defmodule <%= base %>Web.ConfirmView do
  use <%= base %>Web, :view<%= if api do %>

  def render("info.json", %{info: message}) do
    %{info: %{detail: message}}
  end<% end %>
end
