defmodule <%= base %>.AccountsTest do
  use <%= base %>.DataCase

  alias <%= base %>.Accounts
  alias <%= base %>.Accounts.User

  @create_attrs %{email: "fred@mail.com", password: "mangoes&gooseberries"}
  @update_attrs %{email: "frederick@mail.com"}
  @invalid_attrs %{email: nil}<%= if confirm do %>
  @confirm_key "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"<% end %>

  def fixture(:user, attrs \\ @create_attrs) do<%= if confirm do %>
    {:ok, user} = Accounts.create_user(attrs, @confirm_key)<% else %>
    {:ok, user} = Accounts.create_user(attrs)<% end %>
    user
  end

  test "list_users/1 returns all users" do
    user = fixture(:user)
    assert Accounts.list_users() == [user]
  end

  test "get_user! returns the user with given id" do
    user = fixture(:user)
    assert Accounts.get_user!(user.id) == user
  end

  test "create_user/1 with valid data creates a user" do<%= if confirm do %>
    assert {:ok, %User{} = user} = Accounts.create_user(@create_attrs, @confirm_key)<% else %>
    assert {:ok, %User{} = user} = Accounts.create_user(@create_attrs)<% end %>
    assert user.email == "fred@mail.com"
  end

  test "create_user/1 with invalid data returns error changeset" do
    assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
  end

  test "update_user/2 with valid data updates the user" do
    user = fixture(:user)
    assert {:ok, user} = Accounts.update_user(user, @update_attrs)
    assert %User{} = user
    assert user.email == "frederick@mail.com"
  end

  test "update_user/2 with invalid data returns error changeset" do
    user = fixture(:user)
    assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    assert user == Accounts.get_user!(user.id)
  end

  test "delete_user/1 deletes the user" do
    user = fixture(:user)
    assert {:ok, %User{}} = Accounts.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
  end

  test "change_user/1 returns a user changeset" do
    user = fixture(:user)
    assert %Ecto.Changeset{} = Accounts.change_user(user)
  end<%= if confirm do %>

  test "add_reset_token returns" do
  end<% end %>

end
