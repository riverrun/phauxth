defmodule Mix.Tasks.Phauxth.New do
  use Mix.Task

  import Mix.Generator

  @moduledoc """
  Create modules for basic authorization.

  ## Options and arguments

  There are two options:

    * api - create files to authenticate an api instead of a html application
      * the default is false
    * confirm - create files for email / phone confirmation and password resetting
      * the default is false

  ## Examples

  In the root directory of your project, run the following command:

      mix phauxth.new

  To create files for an api, run the following command:

      mix phauxth.new --api

  To add email / phone confirmation:

      mix phauxth.new --confirm

  """

  @phx_base [{:eex, "auth_case.ex", "test/support/auth_case.ex"},
    {:eex, "repo_seeds.exs", "priv/repo/seeds.exs"},
    {:eex, "user.ex", "/accounts/user.ex"},
    {:eex, "user_migration.exs", "priv/repo/migrations/timestamp_create_users.exs"},
    {:eex, "accounts.ex", "/accounts/accounts.ex"},
    {:eex, "accounts_test.exs", "test/namespace/accounts/accounts_test.exs"},
    {:eex, "router.ex", "_web/router.ex"},
    {:eex, "authorize.ex", "_web/controllers/authorize.ex"},
    {:eex, "session_controller.ex", "_web/controllers/session_controller.ex"},
    {:eex, "session_controller_test.exs", "test/namespace_web/controllers/session_controller_test.exs"},
    {:eex, "session_view.ex", "_web/views/session_view.ex"},
    {:eex, "user_controller.ex", "_web/controllers/user_controller.ex"},
    {:eex, "user_controller_test.exs", "test/namespace_web/controllers/user_controller_test.exs"},
    {:eex, "user_view.ex", "_web/views/user_view.ex"}]

  @phx_api [{:eex, "fallback_controller.ex", "_web/controllers/fallback_controller.ex"},
    {:eex, "auth_view.ex", "_web/views/auth_view.ex"},
    {:eex, "changeset_view.ex", "_web/views/changeset_view.ex"}]

  @phx_html [{:text, "layout_app.html.eex", "_web/templates/layout/app.html.eex"},
    {:text, "page_index.html.eex", "_web/templates/page/index.html.eex"},
    {:text, "session_new.html.eex", "_web/templates/session/new.html.eex"},
    {:text, "edit.html.eex", "_web/templates/user/edit.html.eex"},
    {:text, "index.html.eex", "_web/templates/user/index.html.eex"},
    {:text, "new.html.eex", "_web/templates/user/new.html.eex"},
    {:text, "show.html.eex", "_web/templates/user/show.html.eex"}]

  @phx_confirm [{:eex, "message.ex", "_web/message.ex"},
    {:eex, "confirm_controller.ex", "_web/controllers/confirm_controller.ex"},
    {:eex, "confirm_controller_test.exs", "test/namespace_web/controllers/confirm_controller_test.exs"},
    {:eex, "confirm_view.ex", "_web/views/confirm_view.ex"},
    {:eex, "password_reset_controller.ex", "_web/controllers/password_reset_controller.ex"},
    {:eex, "password_reset_controller_test.exs", "test/namespace_web/controllers/password_reset_controller_test.exs"},
    {:eex, "password_reset_view.ex", "_web/views/password_reset_view.ex"}]

  @phx_html_confirm [{:text, "password_reset_new.html.eex", "_web/templates/password_reset/new.html.eex"},
    {:text, "password_reset_edit.html.eex", "_web/templates/password_reset/edit.html.eex"}]

  root = Path.expand("../templates", __DIR__)
  all_files = @phx_base ++ @phx_api ++ @phx_html ++ @phx_confirm ++ @phx_html_confirm

  for {_, source, _} <- all_files do
    @external_resource Path.join(root, source)
    def render(unquote(source)), do: unquote(File.read!(Path.join(root, source)))
  end

  @doc false
  def run(args) do
    check_directory()
    switches = [api: :boolean, confirm: :boolean]
    {opts, _, _} = OptionParser.parse(args, switches: switches)

    {api, confirm} = {opts[:api] == true, opts[:confirm] == true}

    files = @phx_base ++ case {api, confirm} do
      {true, true} -> @phx_api ++ @phx_confirm
      {true, _} -> @phx_api
      {_, true} -> @phx_html ++ @phx_confirm ++ @phx_html_confirm
      _ -> @phx_html
    end

    copy_files(files, base: base_module(), api: api, confirm: confirm)
    if api || confirm, do: update_config()

    Mix.shell.info """

    We are almost ready!

    You need to first edit the `mix.exs` file, adding `{:phauxth, "~> 0.17"},`
    and one of the following: `{:argon2_elixir, "~> 1.2"},`, `{:bcrypt_elixir, "~> 0.12"},`
    or `{:pbkdf2_elixir, "~> 0.12"},` (see the documentation for Comeonin for
    more information about these libraries) to the deps. Then, run `mix deps.get`.

    #{confirm_message(confirm)}

    To run the tests:

        mix test

    And to start the server:

        mix phx.server

    """
  end

  defp check_directory do
    if Mix.Project.config |> Keyword.fetch(:app) == :error do
      Mix.raise "Not in a Mix project. Please make sure you are in the correct directory."
    end
  end

  defp copy_files(files, opts) do
    for {format, source, target} <- files do
      name = base_name()
      target = case target do
        "priv" <> _ -> String.replace(target, "timestamp", timestamp())
        "test/namespace" <> _ -> String.replace(target, "test/namespace", "test/#{name}")
        "test" <> _ -> target
        _ -> "lib/#{name}" <> target
      end
      contents = case format do
        :text -> render(source)
        :eex  -> EEx.eval_string(render(source), opts)
      end
      create_file target, contents
    end
  end

  defp update_config do
    entry = "config :phauxth,\n  token_salt: \"#{gen_token_salt(8)}\"" <>
      ",\n  endpoint: <%= endpoint %>"
      |> EEx.eval_string(endpoint: inspect(get_endpoint()))
    {:ok, conf} = File.read("config/config.exs")
    new_conf = String.split(conf, "\n\n")
               |> List.insert_at(-3, entry)
               |> Enum.join("\n\n")
    File.write("config/config.exs", new_conf)
  end

  defp base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string
  end

  defp base_module do
    base_name() |> Macro.camelize
  end

  defp get_endpoint do
    web = base_name() <> "_web"
    Macro.camelize(web)
    |> Module.concat(Endpoint)
  end

  defp gen_token_salt(length) do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  defp confirm_message(true) do
    """

    You will need to edit the Message module, which is in the web directory.
    Add the email / phone library of your choice to this module and edit the
    functions so that they send messages to the user.
    """
  end
  defp confirm_message(_), do: ""

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end
