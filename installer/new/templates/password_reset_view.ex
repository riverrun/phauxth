defmodule <%= base %>Web.PasswordResetView do
  use <%= base %>Web, :view<%= if api do %>

  def render("error.json", %{error: message}) do
    %{errors: %{detail: message}}
  end

  def render("info.json", %{info: message}) do
    %{info: %{detail: message}}
  end<% end %>
end
