#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Batch email verification

require_relative '../lib/emaillistchecker'

# Replace with your actual API key
API_KEY = 'your_api_key_here'

begin
  # Initialize client
  client = EmailListChecker.new(API_KEY)

  # List of emails to verify
  emails = [
    'user1@example.com',
    'user2@example.com',
    'user3@example.com',
    'invalid@invalid-domain-xyz.com',
    'test@gmail.com'
  ]

  puts "Submitting batch of #{emails.length} emails..."

  # Submit batch
  batch = client.verify_batch(emails, name: 'My Test Batch')
  batch_id = batch['id']

  puts 'Batch submitted successfully!'
  puts "Batch ID: #{batch_id}"
  puts "Status: #{batch['status']}"
  puts "Total emails: #{batch['total_emails']}\n"

  # Monitor progress
  puts 'Monitoring progress...'
  previous_progress = 0

  loop do
    status = client.get_batch_status(batch_id)

    if status['progress'] != previous_progress
      puts "Progress: #{status['progress']}% (#{status['processed_emails']}/#{status['total_emails']} processed)"
      previous_progress = status['progress']
    end

    break if status['status'] == 'completed'

    if status['status'] == 'failed'
      puts "\nBatch verification failed!"
      exit 1
    end

    sleep 2  # Wait 2 seconds before checking again
  end

  puts "\nBatch verification completed!\n"

  # Get final statistics
  final_status = client.get_batch_status(batch_id)
  puts '=== Final Statistics ==='
  puts "Total: #{final_status['total_emails']}"
  puts "Valid: #{final_status['valid_emails']}"
  puts "Invalid: #{final_status['invalid_emails']}"
  puts "Unknown: #{final_status['unknown_emails']}\n"

  # Download results
  puts 'Downloading results...'
  results = client.get_batch_results(batch_id, format: 'json', filter: 'all')

  puts "\n=== Results ==="
  results['data'].each do |result|
    status_icon = case result['result']
                  when 'deliverable' then '✓'
                  when 'undeliverable' then '✗'
                  when 'risky' then '⚠'
                  else '?'
                  end

    puts "#{status_icon} #{result['email']}: #{result['result']} (#{result['reason']})"
  end
rescue EmailListChecker::Error => e
  puts "Error: #{e.message}"
  puts "Status Code: #{e.status_code}" if e.status_code
end
