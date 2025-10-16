#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Verify a single email address

require_relative '../lib/emaillistchecker'

# Replace with your actual API key
API_KEY = 'your_api_key_here'

begin
  # Initialize client
  client = EmailListChecker.new(API_KEY)

  # Verify an email
  puts 'Verifying email...'
  result = client.verify('test@example.com')

  # Display results
  puts "\n=== Verification Result ==="
  puts "Email: #{result['email']}"
  puts "Result: #{result['result']}"
  puts "Reason: #{result['reason']}"
  puts "Score: #{result['score']}"
  puts "\n=== Email Details ==="
  puts "Disposable: #{result['disposable'] ? 'Yes' : 'No'}"
  puts "Role-based: #{result['role'] ? 'Yes' : 'No'}"
  puts "Free provider: #{result['free'] ? 'Yes' : 'No'}"
  puts "SMTP Provider: #{result['smtp_provider']}"
  puts "Domain: #{result['domain']}"

  if result['mx_records'] && !result['mx_records'].empty?
    puts "\nMX Records:"
    result['mx_records'].each do |mx|
      puts "  - #{mx}"
    end
  end
rescue EmailListChecker::Error => e
  puts "Error: #{e.message}"
  puts "Status Code: #{e.status_code}" if e.status_code
end
