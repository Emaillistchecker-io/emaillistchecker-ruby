# frozen_string_literal: true

module EmailListChecker
  # Base exception for EmailListChecker SDK
  class Error < StandardError
    attr_reader :status_code, :response_data

    def initialize(message = nil, status_code: nil, response_data: nil)
      super(message)
      @status_code = status_code
      @response_data = response_data
    end
  end

  # Exception raised when API authentication fails
  class AuthenticationError < Error
    def initialize(message = 'Invalid API key', status_code: 401, response_data: nil)
      super(message, status_code: status_code, response_data: response_data)
    end
  end

  # Exception raised when account has insufficient credits
  class InsufficientCreditsError < Error
    def initialize(message = 'Insufficient credits', status_code: 402, response_data: nil)
      super(message, status_code: status_code, response_data: response_data)
    end
  end

  # Exception raised when API rate limit is exceeded
  class RateLimitError < Error
    attr_reader :retry_after

    def initialize(message, retry_after: 60, status_code: 429, response_data: nil)
      super(message, status_code: status_code, response_data: response_data)
      @retry_after = retry_after
    end
  end

  # Exception raised when request validation fails
  class ValidationError < Error
    def initialize(message = 'Validation error', status_code: 422, response_data: nil)
      super(message, status_code: status_code, response_data: response_data)
    end
  end

  # Exception raised for general API errors
  class ApiError < Error
  end
end
