# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module EmailListChecker
  # EmailListChecker API Client
  #
  # This class provides methods to interact with the EmailListChecker API.
  class Client
    attr_reader :api_key, :base_url, :timeout

    # Create a new EmailListChecker client instance
    #
    # @param api_key [String] Your EmailListChecker API key
    # @param base_url [String] API base URL (default: https://platform.emaillistchecker.io/api/v1)
    # @param timeout [Integer] Request timeout in seconds (default: 30)
    def initialize(api_key, base_url: 'https://platform.emaillistchecker.io/api/v1', timeout: 30)
      @api_key = api_key
      @base_url = base_url.chomp('/')
      @timeout = timeout
    end

    # Verify a single email address
    #
    # @param email [String] Email address to verify
    # @param timeout [Integer, nil] Verification timeout in seconds (5-60)
    # @param smtp_check [Boolean] Perform SMTP verification (default: true)
    # @return [Hash] Verification result
    def verify(email, timeout: nil, smtp_check: true)
      params = {
        email: email,
        smtp_check: smtp_check
      }
      params[:timeout] = timeout if timeout

      response = request(:post, '/verify', body: params)
      response['data'] || response
    end

    # Submit emails for batch verification
    #
    # @param emails [Array<String>] List of email addresses (max 10,000)
    # @param name [String, nil] Name for this batch
    # @param callback_url [String, nil] Webhook URL for completion notification
    # @param auto_start [Boolean] Start verification immediately (default: true)
    # @return [Hash] Batch submission result
    def verify_batch(emails, name: nil, callback_url: nil, auto_start: true)
      data = {
        emails: emails,
        auto_start: auto_start
      }
      data[:name] = name if name
      data[:callback_url] = callback_url if callback_url

      response = request(:post, '/verify/batch', body: data)
      response['data'] || response
    end

    # Upload file for batch verification (CSV, TXT, or XLSX)
    #
    # @param file_path [String] Path to file (CSV, TXT, or XLSX)
    # @param name [String, nil] Name for this batch
    # @param callback_url [String, nil] Webhook URL for completion notification
    # @param auto_start [Boolean] Start verification immediately (default: true)
    # @return [Hash] Batch submission result
    def verify_batch_file(file_path, name: nil, callback_url: nil, auto_start: true)
      raise Error, "File not found: #{file_path}" unless File.exist?(file_path)

      uri = URI.join(@base_url, '/verify/batch/upload')

      boundary = "----RubyMultipartPost#{rand(1000000)}"

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.read_timeout = @timeout
      http.open_timeout = @timeout

      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{@api_key}"
      request['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
      request['User-Agent'] = 'EmailListChecker-Ruby/1.0.0'

      # Build multipart form data
      post_body = []

      # Add file
      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{File.basename(file_path)}\"\r\n"
      post_body << "Content-Type: application/octet-stream\r\n\r\n"
      post_body << File.read(file_path)
      post_body << "\r\n"

      # Add auto_start
      post_body << "--#{boundary}\r\n"
      post_body << "Content-Disposition: form-data; name=\"auto_start\"\r\n\r\n"
      post_body << auto_start.to_s
      post_body << "\r\n"

      # Add name if provided
      if name
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"name\"\r\n\r\n"
        post_body << name
        post_body << "\r\n"
      end

      # Add callback_url if provided
      if callback_url
        post_body << "--#{boundary}\r\n"
        post_body << "Content-Disposition: form-data; name=\"callback_url\"\r\n\r\n"
        post_body << callback_url
        post_body << "\r\n"
      end

      post_body << "--#{boundary}--\r\n"

      request.body = post_body.join

      response = http.request(request)
      data = handle_response(response)
      data['data'] || data
    rescue Net::OpenTimeout, Net::ReadTimeout
      raise Error, "Request timeout after #{@timeout} seconds"
    rescue StandardError => e
      raise Error, "Request failed: #{e.message}"
    end

    # Get batch verification status
    #
    # @param batch_id [Integer] Batch ID
    # @return [Hash] Batch status
    def get_batch_status(batch_id)
      response = request(:get, "/verify/batch/#{batch_id}")
      response['data'] || response
    end

    # Download batch verification results
    #
    # @param batch_id [Integer] Batch ID
    # @param format [String] Output format - 'json', 'csv', 'txt' (default: 'json')
    # @param filter [String] Filter results - 'all', 'valid', 'invalid', 'risky', 'unknown'
    # @return [Hash, String] Results in requested format
    def get_batch_results(batch_id, format: 'json', filter: 'all')
      response = request(:get, "/verify/batch/#{batch_id}/results", params: { format: format, filter: filter })

      format == 'json' ? (response['data'] || response) : response
    end

    # Find email address by name and domain
    #
    # @param first_name [String] First name
    # @param last_name [String] Last name
    # @param domain [String] Domain (e.g., 'example.com')
    # @return [Hash] Found email information
    def find_email(first_name, last_name, domain)
      response = request(:post, '/finder/email', body: {
        first_name: first_name,
        last_name: last_name,
        domain: domain
      })
      response['data'] || response
    end

    # Find emails by domain
    #
    # @param domain [String] Domain to search
    # @param limit [Integer] Results per request (1-100, default: 10)
    # @param offset [Integer] Pagination offset (default: 0)
    # @return [Hash] Found emails
    def find_by_domain(domain, limit: 10, offset: 0)
      response = request(:post, '/finder/domain', body: {
        domain: domain,
        limit: limit,
        offset: offset
      })
      response['data'] || response
    end

    # Find emails by company name
    #
    # @param company [String] Company name
    # @param limit [Integer] Results limit (1-100, default: 10)
    # @return [Hash] Found emails
    def find_by_company(company, limit: 10)
      response = request(:post, '/finder/company', body: {
        company: company,
        limit: limit
      })
      response['data'] || response
    end

    # Get current credit balance
    #
    # @return [Hash] Credit information
    def get_credits
      response = request(:get, '/credits')
      response['data'] || response
    end

    # Get API usage statistics
    #
    # @return [Hash] Usage statistics
    def get_usage
      response = request(:get, '/usage')
      response['data'] || response
    end

    # Get all verification lists
    #
    # @return [Array] List of verification batches
    def get_lists
      response = request(:get, '/lists')
      response['data'] || response
    end

    # Delete a verification list
    #
    # @param list_id [Integer] List ID to delete
    # @return [Hash] Deletion confirmation
    def delete_list(list_id)
      request(:delete, "/lists/#{list_id}")
    end

    private

    # Make HTTP request to API
    #
    # @param method [Symbol] HTTP method (:get, :post, :delete)
    # @param endpoint [String] API endpoint
    # @param params [Hash, nil] Query parameters
    # @param body [Hash, nil] Request body
    # @return [Hash] Response data
    def request(method, endpoint, params: nil, body: nil)
      uri = URI.join(@base_url, endpoint)
      uri.query = URI.encode_www_form(params) if params

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.read_timeout = @timeout
      http.open_timeout = @timeout

      request = case method
                when :get
                  Net::HTTP::Get.new(uri)
                when :post
                  Net::HTTP::Post.new(uri)
                when :delete
                  Net::HTTP::Delete.new(uri)
                else
                  raise ArgumentError, "Unsupported HTTP method: #{method}"
                end

      request['Authorization'] = "Bearer #{@api_key}"
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'
      request['User-Agent'] = 'EmailListChecker-Ruby/1.0.0'

      request.body = body.to_json if body

      response = http.request(request)
      handle_response(response)
    rescue Net::OpenTimeout, Net::ReadTimeout
      raise Error, "Request timeout after #{@timeout} seconds"
    rescue StandardError => e
      raise Error, "Request failed: #{e.message}"
    end

    # Handle HTTP response
    #
    # @param response [Net::HTTPResponse] HTTP response
    # @return [Hash] Parsed response data
    def handle_response(response)
      data = response.body && !response.body.empty? ? JSON.parse(response.body) : {}

      case response.code.to_i
      when 200..299
        data
      when 401
        raise AuthenticationError.new(data['error'] || 'Invalid API key', response_data: data)
      when 402
        raise InsufficientCreditsError.new(data['error'] || 'Insufficient credits', response_data: data)
      when 422
        raise ValidationError.new(data['message'] || 'Validation error', response_data: data)
      when 429
        retry_after = response['Retry-After']&.to_i || 60
        raise RateLimitError.new(
          "Rate limit exceeded. Retry after #{retry_after} seconds",
          retry_after: retry_after,
          response_data: data
        )
      else
        raise ApiError.new(data['error'] || "API error: #{response.code}", status_code: response.code.to_i, response_data: data)
      end
    end
  end
end
