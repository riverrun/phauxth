# Phauxth Changelog

## Version 1.1.2

* Enhancements
    * token implementation signs and verifies JSON strings
        * this avoids the use of potentially vulnerable term_to_binary / binary_to_term variants

## Version 1.1.0

* Enhancements
    * the endpoint value in the config (used by the Confirm module) is now overridable
        * if necessary, you can set this value in the keyword options
        * this is to make it easier to use Phauxth with umbrella apps
    * key options are passed on to Phauxth.Token
        * this applies to the Authenticate, Remember and Confirm modules
    * minor updates to the installer templates - to make it more umbrella-friendly
