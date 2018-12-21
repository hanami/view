source 'https://rubygems.org'

gemspec

gem 'inflecto'

group :tools do
  gem 'hotch'
  gem 'pry-byebug', platform: :mri
end

group :test do
  gem "rack", ">= 2.0.6"

  gem "erubi"
  gem "haml", "~> 5.0"
  gem 'slim', "~> 4.0"

  gem 'simplecov'
  gem 'codeclimate-test-reporter'
end

group :benchmarks do
  gem 'benchmark-ips'
  gem 'actionview'
  gem 'actionpack'
end
