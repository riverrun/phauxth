defmodule Phauxth.UserMessages.Base do
  @moduledoc """
  Customizable module to be used to display messages to users.

  These messages can be customized to display different messages or
  add translations using gettext.

  ## Custom messages

  The following module is a basic example of how to translate the
  user messages that Phauxth outputs:

      defmodule MyApp.UserMessages do
        use Phauxth.UserMessages.Base
        import MyApp.Gettext

        def default_error, do: gettext "Invalid credentials"
      end

  """

  @callback already_confirmed() :: String.t()
  @callback default_error() :: String.t()

  defmacro __using__(_) do
    quote do
      @behaviour Phauxth.UserMessages.Base

      def already_confirmed, do: "Your account has already been confirmed"
      def default_error, do: "Invalid credentials"

      defoverridable Phauxth.UserMessages.Base
    end
  end
end

defmodule Phauxth.UserMessages do
  use Phauxth.UserMessages.Base
end
