Code.require_file "mix_helper.exs", __DIR__

defmodule Mix.Tasks.Phauxth.NewTest do
  use ExUnit.Case
  import MixHelper

  setup do
    Mix.Task.clear
    :ok
  end

  test "generates default html resource" do
    in_tmp "generates default html resource", fn ->
      Mix.Tasks.Phauxth.New.run []

      assert_file "lib/phauxth_new_web/controllers/authorize.ex"
      assert_file "lib/phauxth_new_web/templates/session/new.html.eex"

      refute_file "lib/phauxth_new/accounts/message.ex"
      refute_file "lib/phauxth_new/mailer.ex"

      assert_file "config/config.exs", fn file ->
        assert file =~ ~s(config :phauxth)
      end

      assert_file "lib/phauxth_new_web/router.ex", fn file ->
        assert file =~ ~s(plug Phauxth.Authenticate)
        assert file =~ ~s(resources "/sessions", SessionController, only: [:new, :create, :delete])
        refute file =~ ~s(plug Phauxth.Remember)
      end

      assert_file "lib/phauxth_new_web/controllers/session_controller.ex", fn file ->
        assert file =~ ~s(alias Phauxth.Login)
        assert file =~ "Login.add_session(conn, session_id, user.id)"
        refute file =~ ~s(Phauxth.Remember.delete_rem_cookie)
      end

      assert_file "lib/phauxth_new_web/views/user_view.ex", fn file ->
        refute file =~ "%{info: %{detail: message}}"
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s(You need to first edit the `mix.exs` file)
      assert message =~ ~s({:phauxth, "~> 1.2"})
      assert message =~ ~s(And to start the server)
    end
  end

  test "generates confirm functionality" do
    in_tmp "generates confirm functionality", fn ->
      Mix.Tasks.Phauxth.New.run ["--confirm"]

      assert_file "lib/phauxth_new_web/controllers/confirm_controller.ex"
      assert_file "test/phauxth_new_web/controllers/confirm_controller_test.exs"

      assert_file "config/config.exs", fn file ->
        assert file =~ ~s(config :phauxth)
      end

      assert_file "lib/phauxth_new/mailer.ex", fn file ->
        assert file =~ ~s(use Bamboo.Mailer, otp_app: :phauxth_new)
      end

      assert_file "lib/phauxth_new_web/router.ex", fn file ->
        assert file =~ ~s(plug Phauxth.Authenticate)
        assert file =~ ~s(resources "/password_resets", PasswordResetController, only: [:new, :create])
      end

      assert_file "lib/phauxth_new_web/controllers/session_controller.ex", fn file ->
        assert file =~ ~s(alias Phauxth.Confirm)
      end

      assert_file "test/support/auth_case.ex", fn file ->
        assert file =~ "import Ecto.Changeset"
        assert file =~ "change(%{confirmed_at: DateTime.utc_now})"
      end

      assert_file "lib/phauxth_new/accounts/user.ex", fn file ->
        assert file =~ "field :confirmed_at, :utc_datetime"
        assert file =~ "cast(attrs, [:email, :password])"
      end

      assert_file "lib/phauxth_new/accounts/accounts.ex", fn file ->
        assert file =~ "change(user, %{confirmed_at: DateTime.utc_now})"
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s(need to add bamboo to the deps)
    end
  end

  test "generates remember me" do
    in_tmp "generates remember me", fn ->
      Mix.Tasks.Phauxth.New.run ["--remember"]

      assert_file "lib/phauxth_new_web/router.ex", fn file ->
        assert file =~ ~s(plug Phauxth.Remember)
      end

      assert_file "lib/phauxth_new_web/controllers/session_controller.ex", fn file ->
        assert file =~ ~s(Phauxth.Remember.delete_rem_cookie)
      end

    end
  end

  test "generates api files" do
    in_tmp "generates api files", fn ->
      Mix.Tasks.Phauxth.New.run ["--api"]

      assert_file "lib/phauxth_new_web/views/auth_view.ex"
      assert_file "lib/phauxth_new_web/controllers/authorize.ex"

      refute_file "lib/phauxth_new/accounts/message.ex"
      refute_file "lib/phauxth_new/mailer.ex"

      assert_file "config/config.exs", fn file ->
        assert file =~ ~s(config :phauxth,\n  token_salt: ")
        assert file =~ ~s(endpoint: PhauxthNewWeb.Endpoint)
      end

      assert_file "lib/phauxth_new_web/router.ex", fn file ->
        assert file =~ ~s(plug Phauxth.Authenticate, method: :token)
        assert file =~ ~s(post "/sessions", SessionController, :create)
      end

      assert_file "lib/phauxth_new_web/controllers/session_controller.ex", fn file ->
        assert file =~ ~s(PhauxthNewWeb.SessionView, "info.json", %{info: token})
      end

      assert_file "lib/phauxth_new_web/views/user_view.ex", fn file ->
        assert file =~ ~s(%{data: render_one(user, UserView, "user.json"\)})
      end
    end
  end

  test "generates api files with confirmation" do
    in_tmp "generates api files with confirmation", fn ->
      Mix.Tasks.Phauxth.New.run ["--api", "--confirm"]

      assert_file "lib/phauxth_new_web/controllers/confirm_controller.ex"
      assert_file "lib/phauxth_new_web/views/confirm_view.ex"

      assert_file "config/config.exs", fn file ->
        assert file =~ ~s(config :phauxth,\n  token_salt: ")
        assert file =~ ~s(endpoint: PhauxthNewWeb.Endpoint)
      end

      assert_file "lib/phauxth_new/mailer.ex", fn file ->
        assert file =~ ~s(use Bamboo.Mailer, otp_app: :phauxth_new)
      end

      assert_file "lib/phauxth_new_web/router.ex", fn file ->
        assert file =~ ~s(plug Phauxth.Authenticate, method: :token)
        assert file =~ ~s(post "/password_resets", PasswordResetController, :create)
      end

      assert_file "lib/phauxth_new_web/views/auth_view.ex"
      assert_file "lib/phauxth_new_web/controllers/password_reset_controller.ex"

      assert_file "lib/phauxth_new_web/views/password_reset_view.ex", fn file ->
        assert file =~ "%{info: %{detail: message}}"
      end
    end
  end
end
