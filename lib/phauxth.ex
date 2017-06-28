defmodule Phauxth do
  @moduledoc """
  A collection of functions to be used to authenticate Phoenix web apps.

  Phauxth is designed to be secure, extensible and well-documented.

  Phauxth offers two types of functions: Plugs, which are called with plug,
  and verify/2 functions, which are called inside the function bodies.

  ## Plugs

  Plugs take a conn (connection) struct and opts as arguments and return
  a conn struct.

  ### Authenticate

  Phauxth.Authenticate checks to see if there is a valid cookie or token
  for the user and sets the current_user value accordingly.

  This is usually added to the pipeline you want to authenticate in the
  router.ex file, as in the following example.

      pipeline :browser do
        plug Phauxth.Authenticate
      end

  ### Remember

  This Plug provides a check for a remember_me cookie.

      pipeline :browser do
        plug Phauxth.Authenticate
        plug Phauxth.Remember
      end

  This needs to be called after plug Phauxth.Authenticate.

  ## Phauxth verify/2

  Each verify/2 function takes a map (usually Phoenix params) and opts
  (an empty list by default) and returns {:ok, user} or {:error, message}.

  ### Login and One-time passwords

  In the example below, Phauxth.Login.verify is called within the create
  function in the session controller.

      def create(conn, %{"session" => params}) do
        case Phauxth.Login.verify(params) do
          {:ok, user} -> handle_successful_login
          {:error, message} -> handle_error
        end
      end

  Phauxth.Otp.verify is used for logging in with one-time passwords, which
  are often used with two-factor authentication. It is used in the same
  way as Phauxth.Login.verify.

  ### User confirmation

  Phauxth.Confirm.verify is used for user confirmation, using email or phone,
  and Phauxth.Confirm.PassReset.verify is used for password resetting.

  ## Phauxth with a new Phoenix project

  The easiest way to get started is to use the phauxth_new installer.
  First, download and install it:

      mix archive.install https://github.com/riverrun/phauxth/raw/master/installer/archives/phauxth_new.ez

  Then run the `mix phauxth.new` command in the main directory of the
  Phoenix app. The following options are available:

    * `--api` - create files for an api
    * `--confirm` - add files for email confirmation

  ## Customizing Phauxth

  See the documentation for Phauxth.Authenticate.Base, Phauxth.Login.Base
  and Phauxth.Confirm.Base for more information on extending these modules.

  You can find more information at the
  [Phauxth wiki](https://github.com/riverrun/phauxth/wiki).

  """

end
