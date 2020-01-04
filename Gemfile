source 'https://rubygems.org'

eval_gemfile 'Gemfile.devtools'

gemspec

group :tools do
  gem 'hotch'
  gem 'pry-byebug', platform: :mri
end

group :test do
  gem "rack", ">= 2.0.6"

  gem "erbse"
  gem "erubi"
  gem "hamlit"
  gem "hamlit-block"
  gem 'slim', "~> 4.0"
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
