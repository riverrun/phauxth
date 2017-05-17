defmodule Phauxth do
  @moduledoc """
  A collection of functions to be used to authenticate Phoenix web apps.

  Phauxth is designed to be secure, extensible and well-documented.

  The following functionality is provided by Phauxth (see the
  `Customizing Phauxth` section below for more information about
  extending this functionality).

  ## Authentication

    * Phauxth.Authenticate
      * authenticate the user, using Plug sessions or Phoenix tokens
      * set the current_user value
    * Phauxth.Remember
      * authenticates the user using a remember_me cookie
      * There are also helper functions provided to add and delete the
      remember_me cookie.

  ## Login

    * Phauxth.Login.verify
      * login using a password
      * this uses Comeonin.Bcrypt by default, but a custom hash function can be used
    * Phauxth.Otp.verify
      * login using a one-time password

  ## Email / phone confirmation and password resetting

    * Phauxth.Confirm.verify
      * user confirmation
    * Phauxth.Confirm.PassReset.verify
      * password resetting using email / phone confirmation

  ## Getting started with Phauxth

  The easiest way to get started is to use the phauxth_new
  installer. First, download and install it:

      mix archive.install https://github.com/riverrun/phauxth/raw/master/installer/archives/phauxth_new.ez

  Then run the `mix phauxth.new` command in the main directory
  of the Phoenix app. The following options are available:

    * `--api` - create files for an api
    * `--confirm` - add files for email confirmation

  ## Customizing Phauxth

  See the documentation for Phauxth.Authenticate.Base, Phauxth.Login.Base
  and Phauxth.Confirm.Base for more information on extending these modules.

  You can find more information at the
  [Phauxth wiki](https://github.com/riverrun/phauxth/wiki).

  """

  @callback verify(map, Keyword.t) ::
    {:ok, user :: Ecto.Schema.t} | {:error, message :: String.t}

end
