# frozen_string_literal: true

source "https://rubygems.org"

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
  gem "dry-core", github: "dry-rb/dry-core", branch: "feature/basic-object"
  gem "dry-files", github: "dry-rb/dry-files", branch: "master"
  gem "hanami-cli", github: "hanami/cli", branch: "main"
  gem "hanami", github: "hanami/hanami", branch: "feature/hanami-2-helpers"
  gem "hanami-controller", github: "hanami/controller", branch: "main"
  gem "hanami-router", github: "hanami/router", branch: "main"
  gem "hanami-helpers", github: "hanami/helpers", branch: "rewrite/hanami-2"
  gem "hanami-devtools", github: "hanami/devtools", branch: "main"
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
