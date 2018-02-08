# frozen_string_literal: true

require 'modern/struct'

module Modern
  class Configuration < Modern::Struct
    # TODO: once Modern is done, figure out sane defaults.
    attribute :show_errors, Modern::Types::Strict::Bool.default(true)
    attribute :log_input_converter_errors, Modern::Types::Strict::Bool.default(true)

    attribute :validate_responses, Modern::Types::Strict::String.default("log").enum("no", "log", "error")
  end
end
