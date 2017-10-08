Mix.shell(Mix.Shell.Process)

defmodule MixHelper do
  import ExUnit.Assertions

  @main_config "use Mix.Config\n\nconfig :myapp,\necto_repos: [MyApp.Repo]\n\n" <>
    "config :myapp, MyAppWeb.Endpoint,\nurl: [host: \"localhost\"]\n\n" <>
    "config :logger, :console\n\nimport_config Mix.env.exs"
  @test_config "use Mix.Config\n\nconfig :logger, level: :warn"

  def tmp_path do
    Path.expand("../../tmp", __DIR__)
  end

  def in_tmp(which, function) do
    path = Path.join(tmp_path(), String.replace(which, " ", "_"))
    File.rm_rf!(path)
    File.mkdir_p!(path)
    create_config(Path.join(path, "config"))
    File.cd!(path, function)
  end

  def assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
  end

  def refute_file(file) do
    refute File.regular?(file), "Expected #{file} to not exist, but it does"
  end

  def assert_file(file, match) do
    cond do
      is_list(match) ->
      assert_file file, &(Enum.each(match, fn(m) -> assert &1 =~ m end))
      is_binary(match) or Regex.regex?(match) ->
        assert_file file, &(assert &1 =~ match)
      is_function(match, 1) ->
        assert_file(file)
        match.(File.read!(file))
    end
  end

  defp create_config(config_path) do
    File.mkdir_p!(config_path)
    config_file = Path.join(config_path, "config.exs")
    File.write!(config_file, @main_config)
    test_config_path = Path.join(config_path, "test.exs")
    File.write!(test_config_path, @test_config)
  end
end
