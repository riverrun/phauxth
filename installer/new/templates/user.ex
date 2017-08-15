defmodule <%= base %>.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias <%= base %>.Accounts.User

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string<%= if confirm do %>
    field :confirmed_at, :utc_datetime
    field :reset_sent_at, :utc_datetime<% end %>

    timestamps()
  end

  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end

  def create_changeset(%User{} = user, attrs) do
    user
    |> changeset(attrs)
    |> validate_password(:password)
    |> put_pass_hash()
  end

  # In the function below, strong_password? just checks that the password
  # is at least 8 characters long.
  # See the documentation for NotQwerty123.PasswordStrength.strong_password?
  # for a more comprehensive password strength checker.
  def validate_password(changeset, field, options \\ []) do
    validate_change(changeset, field, fn _, password ->
      case strong_password?(password) do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || msg}]
      end
    end)
  end

  def put_pass_hash(%Ecto.Changeset{valid?: true, changes:
      %{password: password}} = changeset) do
    change(changeset, Comeonin.Bcrypt.add_hash(password))
  end
  def put_pass_hash(changeset), do: changeset

  defp strong_password?(password) when byte_size(password) > 7 do
    {:ok, password}
  end
  defp strong_password?(_), do: {:error, "The password is too short"}
end
