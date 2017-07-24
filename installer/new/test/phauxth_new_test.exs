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

      assert_file "lib/phauxth_new/web/controllers/authorize.ex"
      assert_file "lib/phauxth_new/web/templates/session/new.html.eex"

      assert_file "lib/phauxth_new/web/router.ex", fn file ->
        assert file =~ ~s(plug Phauxth.Authenticate)
        assert file =~ ~s(resources "/sessions", SessionController, only: [:new, :create, :delete])
      end

      assert_file "lib/phauxth_new/web/controllers/session_controller.ex", fn file ->
        assert file =~ ~s(Phauxth.Login.verify)
        assert file =~ "put_session(conn, :user_id, user.id)"
      end

      assert_file "lib/phauxth_new/web/views/user_view.ex", fn file ->
        refute file =~ "%{info: %{detail: message}}"
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s(You need to first edit the `mix.exs` file)
      assert message =~ ~s({:phauxth, "~> 0.12-rc"})
      assert message =~ ~s(And to start the server)
      refute message =~ ~s(You will need to edit the Message module)
    end
  end

  test "generates confirm functionality" do
    in_tmp "generates confirm functionality", fn ->
      Mix.Tasks.Phauxth.New.run ["--confirm"]

      assert_file "lib/phauxth_new/web/controllers/confirm_controller.ex"
      assert_file "test/web/controllers/confirm_controller_test.exs"

      assert_file "lib/phauxth_new/web/router.ex", fn file ->
        assert file =~ ~s(plug Phauxth.Authenticate)
        assert file =~ ~s(resources "/password_resets", PasswordResetController, only: [:new, :create])
      end

      assert_file "lib/phauxth_new/web/controllers/session_controller.ex", fn file ->
        assert file =~ ~s(Phauxth.Confirm.Login.verify)
      end

      assert_file "test/support/auth_case.ex", fn file ->
        assert file =~ "import Ecto.Changeset"
        assert file =~ ~s(key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg")
        assert file =~ "{:ok, user} = Accounts.add_reset_token"
      end

      assert_file "lib/phauxth_new/accounts/user.ex", fn file ->
        assert file =~ "field :confirmed_at, :utc_datetime"
        assert file =~ "field :confirmation_token, :string"
      end

      assert_file "lib/phauxth_new/accounts/accounts.ex", fn file ->
        assert file =~ "change(%{confirmation_token: key, confirmation_sent_at: DateTime.utc_now})"
        assert file =~ "add_reset_token(%{\"email\" => email}, key) do"
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s(will need to edit the Message module)
    end
  end

  test "generates api files" do
    in_tmp "generates api files", fn ->
      Mix.Tasks.Phauxth.New.run ["--api"]

      assert_file "lib/phauxth_new/web/views/auth_view.ex"
      assert_file "lib/phauxth_new/web/controllers/authorize.ex"

      assert_file "lib/phauxth_new/web/router.ex", fn file ->
        assert file =~ ~s(plug Phauxth.Authenticate, token: PhauxthNew.Web.Endpoint)
        assert file =~ ~s(post "/sessions/create", SessionController, :create)
      end

      assert_file "lib/phauxth_new/web/controllers/session_controller.ex", fn file ->
        assert file =~ ~s(PhauxthNew.Web.SessionView, "info.json", %{info: token})
      end

      assert_file "lib/phauxth_new/web/views/user_view.ex", fn file ->
        assert file =~ ~s(%{data: render_one(user, UserView, "user.json"\)})
      end
    end
  end

  test "generates api files with confirmation" do
    in_tmp "generates api files with confirmation", fn ->
      Mix.Tasks.Phauxth.New.run ["--api", "--confirm"]

      assert_file "lib/phauxth_new/web/controllers/confirm_controller.ex"
      assert_file "lib/phauxth_new/web/views/confirm_view.ex"

      assert_file "lib/phauxth_new/web/router.ex", fn file ->
        assert file =~ ~s(plug Phauxth.Authenticate, token: PhauxthNew.Web.Endpoint)
        assert file =~ ~s(post "/password_resets/create", PasswordResetController, :create)
      end

      assert_file "lib/phauxth_new/web/views/auth_view.ex"
      assert_file "lib/phauxth_new/web/controllers/password_reset_controller.ex"

      assert_file "lib/phauxth_new/web/views/password_reset_view.ex", fn file ->
        assert file =~ "%{info: %{detail: message}}"
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s(will need to edit the Message module)
    end
  end
end
