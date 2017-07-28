ExUnit.start()

Code.require_file "support/access_control.exs", __DIR__
Code.require_file "support/custom_login.exs", __DIR__
Code.require_file "support/session_helper.exs", __DIR__
Code.require_file "support/user_helper.exs", __DIR__

Application.put_env(:phauxth, :token_salt, Phauxth.Config.gen_token_salt())
