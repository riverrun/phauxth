defmodule Mix.Tasks.Phauxth.New do
  use Mix.Task

  @moduledoc """
  Create modules for basic authorization.

  ## Options and arguments

  There are four options:

    * api - create files to authenticate an api instead of a html application
      * the default is false
    * confirm - create files for email / phone confirmation and password resetting
      * the default is false
    * remember - add functions to enable `remember_me` functionality
      * the default is false
    * backups - if a file already exists, save the old version as a backup file
      * the default is true
      * the old version will be saved with the `.bak` extension

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
    {:eex, "session_new.html.eex", "_web/templates/session/new.html.eex"},
    {:eex, "edit.html.eex", "_web/templates/user/edit.html.eex"},
    {:text, "index.html.eex", "_web/templates/user/index.html.eex"},
    {:text, "new.html.eex", "_web/templates/user/new.html.eex"},
    {:text, "show.html.eex", "_web/templates/user/show.html.eex"}]

  @phx_confirm [{:eex, "message.ex", "/accounts/message.ex"},
    {:eex, "mailer.ex", "/mailer.ex"},
    {:eex, "message_test.exs", "test/namespace/accounts/message_test.exs"},
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
    switches = [api: :boolean,
                confirm: :boolean,
                remember: :boolean,
                backups: :boolean]
    {opts, _, _} = OptionParser.parse(args, switches: switches)

    {api, confirm, remember, backups} = {opts[:api] == true, opts[:confirm] == true,
      opts[:remember] == true, opts[:backups] != false}

    files = @phx_base ++ case {api, confirm} do
      {true, true} -> @phx_api ++ @phx_confirm
      {true, _} -> @phx_api
      {_, true} -> @phx_html ++ @phx_confirm ++ @phx_html_confirm
      _ -> @phx_html
    end

    base_name = base_name()
    base = base_name |> Macro.camelize

    copy_files(files, base_name: base_name, base: base, api: api,
               confirm: confirm, remember: remember, backups: backups)
    update_config(confirm, base_name, base)

    Mix.shell.info """

    We are almost ready!

    You need to first edit the `mix.exs` file, adding `{:phauxth, "~> 1.2"},`
    to it. You also need to add one of the following password hashing libraries:
    `argon2_elixir`, `bcrypt_elixir` or `pbkdf2_elixir` (see the documentation
    for Comeonin for more information about these libraries) to the deps.
    #{confirm_deps_message(confirm)}

    For more information about authorization, see the authorize.ex file
    in the controllers directory. You can see how the `user_check` and
    `id_check` functions are used in the user_controller.ex file.

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
      create_file(target, contents, opts[:backups])
    end
  end

  defp create_file(path, contents, create_backups) do
    if File.exists?(path) and create_backups do
      backup = path <> ".bak"
      Mix.shell.info [:green, "* creating ", :reset, Path.relative_to_cwd(backup)]
      File.rename(path, backup)
    end
    Mix.shell.info [:green, "* creating ", :reset, Path.relative_to_cwd(path)]
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, contents)
  end

  defp update_config(confirm, base_name, base) do
    entry = config_input(confirm, base_name, base)
            |> EEx.eval_string(endpoint: inspect(get_endpoint(base_name)))

    {:ok, conf} = File.read("config/config.exs")
    new_conf = String.split(conf, "\n\n")
               |> List.insert_at(-3, entry)
               |> Enum.join("\n\n")
    File.write("config/config.exs", new_conf)
    if confirm, do: add_test_config(base_name, base)
  end

  defp base_name do
    Mix.Project.config |> Keyword.fetch!(:app) |> to_string
  end

  defp get_endpoint(base_name) do
    web = base_name <> "_web"
    Macro.camelize(web)
    |> Module.concat(Endpoint)
  end

  defp gen_token_salt(length) do
    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  defp config_input(false, _, _) do
    """
    # Phauxth authentication configuration
    config :phauxth,
      token_salt: \"#{gen_token_salt(8)}\",
      endpoint: <%= endpoint %>
    """
  end
  defp config_input(true, base_name, base) do
    config_input(false, base_name, base) <> """

    # Mailer configuration
    config :#{base_name}, #{base}.Mailer,
      adapter: Bamboo.MandrillAdapter,
      api_key: System.get_env("MANDRILL_API_KEY")
    """
  end

  defp add_test_config(base_name, base) do
    test_entry = """
    \n# Mailer test configuration
    config :#{base_name}, #{base}.Mailer,
      adapter: Bamboo.TestAdapter
    """

    {:ok, test_conf} = File.read("config/test.exs")
    File.write("config/test.exs", test_conf <> test_entry)
  end

  defp confirm_deps_message(true) do
    "You also need to add bamboo to the deps if you are using Bamboo\n" <>
    "to email users. Then, run `mix deps.get`."
  end
  defp confirm_deps_message(_), do: "Then, run `mix deps.get`."

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: << ?0, ?0 + i >>
  defp pad(i), do: to_string(i)
end
