# EmailListChecker Ruby SDK

[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D2.7.0-red.svg)](https://www.ruby-lang.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Official Ruby SDK for the [EmailListChecker](https://emaillistchecker.io) email verification API.

## Features

- **Email Verification** - Verify single or bulk email addresses
- **Email Finder** - Discover email addresses by name, domain, or company
- **Credit Management** - Check balance and usage
- **Batch Processing** - Async verification of large lists
- **Pure Ruby** - No external dependencies (uses standard library)
- **Exception Handling** - Comprehensive error classes
- **RDoc Documentation** - Full documentation support

## Requirements

- Ruby 2.7.0 or higher

## Installation

Install via gem using git:

```bash
gem install specific_install
gem specific_install https://github.com/Emaillistchecker-io/emaillistchecker-ruby.git
```

Or add to your `Gemfile`:

```ruby
gem 'emaillistchecker', git: 'https://github.com/Emaillistchecker-io/emaillistchecker-ruby.git'
```

Then run:

```bash
bundle install
```

## Quick Start

```ruby
require 'emaillistchecker'

# Initialize client
client = EmailListChecker.new('your_api_key_here')

# Verify an email
result = client.verify('test@example.com')
puts "Result: #{result['result']}"  # deliverable, undeliverable, risky, unknown
puts "Score: #{result['score']}"     # 0.0 to 1.0
```

## Get Your API Key

1. Sign up at [platform.emaillistchecker.io](https://platform.emaillistchecker.io/register)
2. Get your API key from the [API Dashboard](https://platform.emaillistchecker.io/api)
3. Start verifying!

## Usage Examples

### Single Email Verification

```ruby
require 'emaillistchecker'

client = EmailListChecker.new('your_api_key')

# Verify single email
result = client.verify('user@example.com')

case result['result']
when 'deliverable'
  puts '✓ Email is valid and deliverable'
when 'undeliverable'
  puts '✗ Email is invalid'
when 'risky'
  puts '⚠ Email is risky (catch-all, disposable, etc.)'
else
  puts '? Unable to determine'
end

# Check details
puts "Disposable: #{result['disposable']}"
puts "Role account: #{result['role']}"
puts "Free provider: #{result['free']}"
puts "SMTP provider: #{result['smtp_provider']}"
```

### Batch Email Verification

```ruby
require 'emaillistchecker'

client = EmailListChecker.new('your_api_key')

# Submit batch for verification
emails = [
  'user1@example.com',
  'user2@example.com',
  'user3@example.com'
]

batch = client.verify_batch(emails, name: 'My Campaign List')
batch_id = batch['id']

puts "Batch ID: #{batch_id}"
puts "Status: #{batch['status']}"

# Check progress
loop do
  status = client.get_batch_status(batch_id)
  puts "Progress: #{status['progress']}%"

  break if status['status'] == 'completed'

  sleep 5  # Wait 5 seconds before checking again
end

# Download results
results = client.get_batch_results(batch_id, format: 'json', filter: 'all')

results['data'].each do |email_data|
  puts "#{email_data['email']}: #{email_data['result']}"
end
```

### Batch Verification with File Upload

You can also upload CSV, TXT, or XLSX files for batch verification:

```ruby
require 'emaillistchecker'

client = EmailListChecker.new('your_api_key')

# Upload file for batch verification
batch = client.verify_batch_file(
  'path/to/emails.csv',
  name: 'My Email List',
  callback_url: nil,  # optional
  auto_start: true
)

batch_id = batch['id']
puts "Batch ID: #{batch_id}"
puts "Total emails: #{batch['total_emails']}"
puts "Filename: #{batch['filename']}"

# Check progress (same as JSON batch)
loop do
  status = client.get_batch_status(batch_id)
  puts "Progress: #{status['progress']}%"

  break if status['status'] == 'completed'

  sleep 5
end

# Download results
results = client.get_batch_results(batch_id, format: 'csv', filter: 'valid')
```

**Supported file formats:**
- CSV (.csv) - Comma-separated values
- TXT (.txt) - Plain text, one email per line
- Excel (.xlsx, .xls) - Excel spreadsheet

**File requirements:**
- Max file size: 10MB
- Max emails: 10,000 per file
- Files are automatically parsed to extract emails

### Email Finder

```ruby
require 'emaillistchecker'

client = EmailListChecker.new('your_api_key')

# Find email by name and domain
result = client.find_email('John', 'Doe', 'example.com')

puts "Found: #{result['email']}"
puts "Confidence: #{result['confidence']}%"
puts "Verified: #{result['verified']}"

# Find all emails for a domain
domain_results = client.find_by_domain('example.com', limit: 50)

domain_results['emails'].each do |email|
  puts "#{email['email']} - Last verified: #{email['last_verified']}"
end

# Find emails by company name
company_results = client.find_by_company('Acme Corporation')

puts "Possible domains: #{company_results['possible_domains'].join(', ')}"
company_results['emails'].each do |email|
  puts "#{email['email']} (#{email['domain']})"
end
```

### Credit Management

```ruby
require 'emaillistchecker'

client = EmailListChecker.new('your_api_key')

# Check credit balance
credits = client.get_credits
puts "Available credits: #{credits['balance']}"
puts "Used this month: #{credits['used_this_month']}"
puts "Current plan: #{credits['plan']}"

# Get usage statistics
usage = client.get_usage
puts "Total API calls: #{usage['total_requests']}"
puts "Successful: #{usage['successful_requests']}"
puts "Failed: #{usage['failed_requests']}"
```

### List Management

```ruby
require 'emaillistchecker'

client = EmailListChecker.new('your_api_key')

# Get all lists
lists = client.get_lists

lists.each do |list|
  puts "ID: #{list['id']}"
  puts "Name: #{list['name']}"
  puts "Status: #{list['status']}"
  puts "Total emails: #{list['total_emails']}"
  puts "Valid: #{list['valid_emails']}"
  puts '---'
end

# Delete a list
client.delete_list(123)
```

## Error Handling

```ruby
require 'emaillistchecker'

client = EmailListChecker.new('your_api_key')

begin
  result = client.verify('test@example.com')
rescue EmailListChecker::AuthenticationError
  puts 'Invalid API key'
rescue EmailListChecker::InsufficientCreditsError
  puts 'Not enough credits'
rescue EmailListChecker::RateLimitError => e
  puts "Rate limit exceeded. Retry after #{e.retry_after} seconds"
rescue EmailListChecker::ValidationError => e
  puts "Validation error: #{e.message}"
rescue EmailListChecker::Error => e
  puts "API error: #{e.message}"
  puts "Status code: #{e.status_code}" if e.status_code
end
```

## API Response Format

### Verification Result

```ruby
{
  'email' => 'user@example.com',
  'result' => 'deliverable',  # deliverable | undeliverable | risky | unknown
  'reason' => 'VALID',         # VALID | INVALID | ACCEPT_ALL | DISPOSABLE | etc.
  'disposable' => false,       # Is temporary/disposable email
  'role' => false,             # Is role-based (info@, support@, etc.)
  'free' => false,             # Is free provider (gmail, yahoo, etc.)
  'score' => 1.0,              # Deliverability score (0.0 - 1.0)
  'smtp_provider' => 'google', # Email provider
  'mx_records' => ['mx1.google.com', 'mx2.google.com'],
  'domain' => 'example.com',
  'spam_trap' => false,
  'mx_found' => true
}
```

## Configuration

### Custom Timeout

```ruby
require 'emaillistchecker'

# Set custom timeout (default: 30 seconds)
client = EmailListChecker.new(
  'your_api_key',
  base_url: 'https://platform.emaillistchecker.io/api/v1',
  timeout: 60  # 60 seconds timeout
)
```

### Custom Base URL

```ruby
require 'emaillistchecker'

# Use custom API endpoint (for testing or private instances)
client = EmailListChecker.new(
  'your_api_key',
  base_url: 'https://custom-api.example.com/api/v1'
)
```

## Development

### Running Tests

```bash
bundle exec rspec
```

### Building the Gem

```bash
gem build emaillistchecker.gemspec
```

## Support

- **Documentation**: [platform.emaillistchecker.io/api](https://platform.emaillistchecker.io/api)
- **Email**: support@emaillistchecker.io
- **Issues**: [GitHub Issues](https://github.com/Emaillistchecker-io/emaillistchecker-ruby/issues)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

Made with ❤️ by [EmailListChecker](https://emaillistchecker.io)
