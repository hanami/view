source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.1.0'
  gem 'yard',   require: false
end

gem 'lotus-utils', '~> 0.5', require: false, github: 'lotus/utils', branch: '0.5.x'
gem 'haml',                  require: false
gem 'simplecov',             require: false
gem 'coveralls',             require: false
