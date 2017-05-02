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

      assert_file "lib/phauxth_new/web/controllers/session_controller.ex", fn file ->
        assert file =~ "plug Phauxth.Login when action in [:create]"
        assert file =~ "put_session(conn, :user_id, id)"
      end

      assert_file "lib/phauxth_new/web/views/user_view.ex", fn file ->
        refute file =~ "%{info: %{detail: message}}"
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s(You need to first edit the `mix.exs` file)
      assert message =~ ~s({:phauxth, "~> 0.8"})
      assert message =~ ~s(And to start the server)
      refute message =~ ~s(will need to create a module that contacts the user, by email)
    end
  end

  test "generates confirm functionality" do
    in_tmp "generates confirm functionality", fn ->
      Mix.Tasks.Phauxth.New.run ["--confirm"]

      assert_file "lib/phauxth_new/web/controllers/confirm_controller.ex"
      assert_file "test/web/controllers/confirm_controller_test.exs"

      assert_file "test/support/auth_case.ex", fn file ->
        assert file =~ "import Ecto.Changeset"
        assert file =~ ~s(key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg")
        assert file =~ "{:ok, user} = Accounts.request_pass_reset"
      end

      assert_file "lib/phauxth_new/accounts/user.ex", fn file ->
        assert file =~ "field :confirmed_at, Ecto.DateTime"
        assert file =~ "field :confirmation_token, :string"
      end

      assert_file "lib/phauxth_new/accounts/accounts.ex", fn file ->
        assert file =~ "change(%{confirmation_token: key, confirmation_sent_at: Ecto.DateTime.utc})"
        assert file =~ "add_reset_token(%{\"email\" => email}, key) do"
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s(will need to create a module that contacts the user, by email)
    end
  end

  test "generates api files" do
    in_tmp "generates api files", fn ->
      Mix.Tasks.Phauxth.New.run ["--api"]

      assert_file "lib/phauxth_new/web/views/auth_view.ex"
      assert_file "lib/phauxth_new/web/controllers/authorize.ex"

      assert_file "lib/phauxth_new/web/controllers/session_controller.ex", fn file ->
        assert file =~ "plug Phauxth.Login when action in [:create]"
        assert file =~ ~s(PhauxthNew.Web.SessionView, "info.json", %{info: token})
      end

      assert_file "lib/phauxth_new/web/views/user_view.ex", fn file ->
        assert file =~ ~s(%{data: render_one(user, UserView, "user.json"\)})
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s(plug Phauxth.Authenticate, context: PhauxthNew.Web.Endpoint)
      assert message =~ ~s(post "/sessions/create", SessionController, :create)
    end
  end

  test "generates api files with confirmation" do
    in_tmp "generates api files with confirmation", fn ->
      Mix.Tasks.Phauxth.New.run ["--api", "--confirm"]

      assert_file "lib/phauxth_new/web/controllers/confirm_controller.ex"
      assert_file "lib/phauxth_new/web/views/confirm_view.ex"

      assert_file "lib/phauxth_new/web/views/auth_view.ex"
      assert_file "lib/phauxth_new/web/controllers/password_reset_controller.ex"

      assert_file "lib/phauxth_new/web/views/password_reset_view.ex", fn file ->
        assert file =~ "%{info: %{detail: message}}"
      end

      assert_received {:mix_shell, :info, ["\nWe are almost ready!" <> _ = message]}
      assert message =~ ~s(plug Phauxth.Authenticate, context: PhauxthNew.Web.Endpoint)
      assert message =~ ~s(will need to create a module that contacts the user, by email)
    end
  end
end
