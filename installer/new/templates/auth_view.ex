defmodule <%= base %>Web.AuthView do
  use <%= base %>Web, :view

  def render("401.json", _assigns) do
    %{errors: %{detail: "You need to login to view this resource"}}
  end

  def render("403.json", _assigns) do
    %{errors: %{detail: "You are not authorized to view this resource"}}
  end

  def render("logged_in.json", _assigns) do
    %{errors: %{detail: "You are already logged in"}}
  end
end
