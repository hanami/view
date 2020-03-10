# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

group :tools do
  gem "hotch"
  gem "pry-byebug", platform: :mri
end

group :test do
  gem "rack", ">= 2.0.6"

  gem "erbse", "~> 0.1.4"
  gem "erubi"
  gem "hamlit"
  gem "hamlit-block"
  gem "slim", "~> 4.0"
end

group :benchmarks do
  gem "actionpack"
  gem "actionview"
  gem "benchmark-ips"
end

group :docs do
  gem "redcarpet", platforms: :mri
  gem "yard"
  gem "yard-junk"
end
