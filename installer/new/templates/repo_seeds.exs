# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use the command `mix ecto.setup`
#

users = [
  %{email: "jane.doe@example.com", password: "password"},
  %{email: "john.smith@example.org", password: "password"}
]

for user <- users do<%= if confirm do %>
  {:ok, user} = <%= base %>.Accounts.create_user(user)
  <%= base %>.Accounts.confirm_user(user)<% else %>
  {:ok, _} = <%= base %>.Accounts.create_user(user)<% end %>
end
