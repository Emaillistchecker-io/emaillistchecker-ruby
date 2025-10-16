#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Check credits and usage

require_relative '../lib/emaillistchecker'

# Replace with your actual API key
API_KEY = 'your_api_key_here'

begin
  # Initialize client
  client = EmailListChecker.new(API_KEY)

  # Get credit balance
  puts '=== Credit Balance ==='
  credits = client.get_credits

  puts "Available credits: #{credits['balance']}"
  puts "Used this month: #{credits['used_this_month']}"
  puts "Current plan: #{credits['plan']}\n"

  # Get usage statistics
  puts '=== Usage Statistics ==='
  usage = client.get_usage

  puts "Total API requests: #{usage['total_requests']}"
  puts "Successful requests: #{usage['successful_requests']}"
  puts "Failed requests: #{usage['failed_requests']}"

  # Calculate success rate
  if usage['total_requests'] > 0
    success_rate = (usage['successful_requests'].to_f / usage['total_requests']) * 100
    puts "Success rate: #{format('%.2f', success_rate)}%"
  end
rescue EmailListChecker::Error => e
  puts "Error: #{e.message}"
  puts "Status Code: #{e.status_code}" if e.status_code
end
