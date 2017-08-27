source 'https://rubygems.org'

gemspec

gem 'inflecto'

group :tools do
  gem 'pry-byebug', platform: :mri
end

group :test do
  gem 'rack', '>= 1.0.0', '<= 2.0.0'
  gem 'slim'

  gem 'simplecov'
  gem 'codeclimate-test-reporter'
end

group :benchmarks do
  gem 'benchmark-ips'
  gem 'actionview'
end
