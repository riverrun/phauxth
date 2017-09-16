defmodule <%= base %>Web.Router do
  use <%= base %>Web, :router<%= if api do %>

  pipeline :api do
    plug :accepts, ["json"]
    plug Phauxth.Authenticate, method: :token
  end

  scope "/api", <%= base %>Web do
    pipe_through :api

    post "/sessions/create", SessionController, :create
    resources "/users", UserController, except: [:new, :edit]<%= if confirm do %>
    get "/confirm", ConfirmController, :index
    post "/password_resets/create", PasswordResetController, :create
    put "/password_resets/update", PasswordResetController, :update<% end %>
  end<% else %>

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phauxth.Authenticate
  end

  pipeline :check_user do
    plug <%= base %>Web.Plugs.CheckUser
  end

  pipeline :check_role_admin do
    plug <%= base %>Web.Plugs.CheckRole, ["admin"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", <%= base %>Web do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController
    resources "/sessions", SessionController, only: [:new, :create, :delete]<%= if confirm do %>
    get "/confirm", ConfirmController, :index
    resources "/password_resets", PasswordResetController, only: [:new, :create]
    get "/password_resets/edit", PasswordResetController, :edit
    put "/password_resets/update", PasswordResetController, :update<% end %>
  end<% end %>

  # # using pipeline-based authentication example
  # scope "/users-only/", <%= base %>Web do
  #   pipe_through :browser
  #   pipe_through :check_user
  #
  #   get "/", PageController, :index
  # end

end
