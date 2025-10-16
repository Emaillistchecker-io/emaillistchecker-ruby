#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Email Finder

require_relative '../lib/emaillistchecker'

# Replace with your actual API key
API_KEY = 'your_api_key_here'

begin
  # Initialize client
  client = EmailListChecker.new(API_KEY)

  # Example 1: Find email by name and domain
  puts '=== Find Email by Name ==='
  result = client.find_email('John', 'Doe', 'example.com')

  puts "Email found: #{result['email']}"
  puts "Confidence: #{result['confidence']}%"
  puts "Pattern: #{result['pattern']}"
  puts "Verified: #{result['verified'] ? 'Yes' : 'No'}"

  if result['alternatives'] && !result['alternatives'].empty?
    puts "\nAlternative patterns:"
    result['alternatives'].each do |alt|
      puts "  - #{alt}"
    end
  end

  puts ''

  # Example 2: Find emails by domain
  puts '=== Find Emails by Domain ==='
  domain_results = client.find_by_domain('example.com', limit: 10)

  puts "Domain: #{domain_results['domain']}"
  puts "Total found: #{domain_results['total_found']}"

  if domain_results['patterns'] && !domain_results['patterns'].empty?
    puts "\nCommon email patterns:"
    domain_results['patterns'].each do |pattern|
      puts "  - #{pattern}"
    end
  end

  puts "\nFound emails:"
  domain_results['emails'].each do |email|
    puts "  - #{email['email']} (Last verified: #{email['last_verified']})"
  end

  puts ''

  # Example 3: Find emails by company
  puts '=== Find Emails by Company ==='
  company_results = client.find_by_company('Acme Corporation', limit: 10)

  puts "Company: #{company_results['company']}"
  puts "Total found: #{company_results['total_found']}"

  if company_results['possible_domains'] && !company_results['possible_domains'].empty?
    puts "\nPossible domains:"
    company_results['possible_domains'].each do |domain|
      puts "  - #{domain}"
    end
  end

  puts "\nFound emails:"
  company_results['emails'].each do |email|
    puts "  - #{email['email']} (#{email['domain']})"
  end
rescue EmailListChecker::Error => e
  puts "Error: #{e.message}"
  puts "Status Code: #{e.status_code}" if e.status_code
end
