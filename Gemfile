# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

eval_gemfile "Gemfile.devtools"

gemspec

group :tools do
  gem "hotch"
  gem "pry-byebug", platform: :mri
end

group :test do
  gem "saharspec"

  gem "dry-inflector"
  gem "erbse", "~> 0.1.4"
  gem "erubi"
  gem "hamlit"
  gem "hamlit-block"
  gem "hanami", github: "hanami/hanami", branch: "unstable"
  gem "hanami-controller", github: "hanami/controller", branch: "unstable"
  gem "hanami-devtools", github: "hanami/devtools"
  gem "rack", ">= 2.0.6"
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
