# frozen_string_literal: true

require "modern/descriptor/parameters"
require "modern/errors/web_errors"
require "modern/struct"

module Modern
  module Descriptor
    module Security
      # TODO: implement OAuth2 security, with flow objects
      # TODO: implement OpenID Connect security

      # Securities in Modern allow for specifying the "plumbing" bits of the
      # security in a predictable, unsurprising way. If you specify that you use
      # HTTP authorization with the `Foobar` scheme--great. Modern finds the
      # authorization header, checks to see if it's Foobar type, and retrieves
      # the value that signifies its authentication. This value will be passed
      # to the validator, which can determine whether or not its a valid bit of
      # authentication.
      #
      # The idea is that, given that the validation gets access to a
      # `PartialRequestContainer` that includes both the request and the
      # application service set, it can connect to the auth server/user
      # database/whatever and make sure it's atually a legitimate user. Since
      # {Modern::Request} has a mutable store in {Modern::Request#local_store},
      # the validator can then store a User object (or whatever) into it for use
      # in the actual application.
      class Base < Modern::Struct
        Type = Types.Instance(self)

        attribute :name, Types::Strict::String
        attribute :description, Types::Strict::String.optional.default(nil)
        attribute :validation, Types::SecurityAction

        def validate(context)
          value = do_validate(context.request)

          if value.nil?
            false
          else
            !!(context.instance_eval &validation)
          end
        end

        private

        def do_validate(_request)
          raise "#{self.class.name}#do_validate(request) must be implemented."
        end
      end

      class ApiKey < Base
        Type = Types.Instance(self)

        attribute :parameter, Parameters::Query::Type | Parameters::Header::Type | Parameters::Cookie::Type

        def initialize(fields)
          super

          # I didn't want to rewrite all my parameter logic.
          raise Modern::Errors::SetupError, "Parameter must not be 'required' (internal limitation)." \
            if parameter.required
        end
      end

      class Http < Base
        # aside: some people think that the Authorization field can support multiple sets of credentials,
        # as RFC 7230 suggests that headers can be sent "multiple" times by using a comma to split them.
        # however, this is for headers like Accept-Encoding. We don't need to split Authorization.
        Type = Types.Instance(self)

        attribute :scheme, Types::Strict::String
      end
    end
  end
end
