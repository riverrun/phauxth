defmodule Phauxth do
  @moduledoc """
  A collection of functions to be used to authenticate Phoenix web apps.

  Phauxth is designed to be secure, extensible and well-documented.

  Phauxth offers two types of functions: Plugs, which are called with plug,
  and verify/3 functions, which are called inside the function bodies.

  ## Plugs

  Plugs take a conn (connection) struct, a context module (MyApp.Accounts
  by default) and opts as arguments and return a conn struct.

  ### Authenticate

  Phauxth.Authenticate checks to see if there is a valid cookie or token
  for the user and sets the current_user value accordingly.

  This is usually added to the pipeline you want to authenticate in the
  router.ex file, as in the following example.

      pipeline :browser do
        plug Phauxth.Authenticate
      end

  To authenticate an api, using Phoenix token, you need to add a token
  key source, which is usually the app's endpoint, but can also be `Plug.Conn`,
  `Phoenix.Socket` or a string representing the secret key base, to this function.

      plug Phauxth.Authenticate, token: MyApp.Web.Endpoint

  ### Remember

  This Plug provides a check for a remember_me cookie.

      pipeline :browser do
        plug Phauxth.Authenticate
        plug Phauxth.Remember
      end

  This needs to be called after plug Phauxth.Authenticate.

  ## Phauxth verify/3

  Each verify/3 function takes a map (usually Phoenix params), a context
  module (usually MyApp.Accounts) and opts (an empty list by default)
  and returns {:ok, user} or {:error, message}.

  ### Login

  In the example below, Phauxth.Login.verify is called within the create
  function in the session controller.

      def create(conn, %{"session" => params}) do
        case Phauxth.Login.verify(params, MyApp.Accounts) do
          {:ok, user} -> handle_successful_login
          {:error, message} -> handle_error
        end
      end

  ### User confirmation and password resetting

  Phauxth.Confirm.verify is used for user confirmation, using email or phone,
  and Phauxth.Confirm.PassReset.verify is used for password resetting.

  The function below is an example of how you would call Phauxth.Confirm.verify.
  Note that the verify function does not update the database or send
  an email to the user. These need to be handled in your app.

      def new(conn, params) do
        case Phauxth.Confirm.verify(params, MyApp.Accounts) do
          {:ok, user} ->
            Accounts.confirm_user(user)
            message = "Your account has been confirmed"
            Message.confirm_success(user.email)
            handle_success(conn, message, session_path(conn, :new))
          {:error, message} ->
            handle_error(conn, message, session_path(conn, :new))
        end
      end

  Similarly, the Phauxth.Confirm.PassReset.verify function does not
  reset the password. Its job is to verify the confirmation key.

  ## Phauxth with a new Phoenix project

  The easiest way to get started is to use the phauxth_new installer.
  First, download and install it:

      mix archive.install https://github.com/riverrun/phauxth/raw/master/installer/archives/phauxth_new.ez

  Then run the `mix phauxth.new` command in the main directory of the
  Phoenix app. The following options are available:

    * `--api` - create files for an api
    * `--confirm` - add files for email confirmation

  Phauxth uses the `get(id)` and `get_by(attrs)` functions in the user Accounts
  module, so make sure that these functions are defined.

  ## Customizing Phauxth

  See the documentation for Phauxth.Authenticate.Base, Phauxth.Login.Base
  and Phauxth.Confirm.Base for more information on extending these modules.

  You can find more information at the
  [Phauxth wiki](https://github.com/riverrun/phauxth/wiki).

  """

end
