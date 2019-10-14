source 'https://rubygems.org'

gemspec

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :tools do
  gem 'hotch'
  gem 'pry-byebug', platform: :mri
  gem 'ossy', github: 'solnic/ossy', branch: 'master'
end

group :test do
  gem "rack", ">= 2.0.6"

  gem "erbse"
  gem "erubi"
  gem "hamlit"
  gem "hamlit-block"
  gem 'slim', "~> 4.0"

  gem 'simplecov'
end

group :benchmarks do
  gem 'benchmark-ips'
  gem 'actionview'
  gem 'actionpack'
end

group :docs do
  gem 'yard'
  gem 'yard-junk'
  gem 'redcarpet', platforms: :mri
end
