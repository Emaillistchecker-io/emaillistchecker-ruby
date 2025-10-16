# frozen_string_literal: true

require_relative 'emaillistchecker/version'
require_relative 'emaillistchecker/exceptions'
require_relative 'emaillistchecker/client'

# EmailListChecker Ruby SDK
# Official Ruby client for the EmailListChecker API
module EmailListChecker
  class << self
    # Create a new EmailListChecker client
    #
    # @param api_key [String] Your EmailListChecker API key
    # @param options [Hash] Additional options
    # @return [EmailListChecker::Client] Client instance
    def new(api_key, **options)
      Client.new(api_key, **options)
    end
  end
end
