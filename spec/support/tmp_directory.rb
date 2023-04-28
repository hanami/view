# frozen_string_literal: true

require "hanami/devtools/integration/files"
require "hanami/devtools/integration/with_tmp_directory"
require "tmpdir"

module RSpec
  module Support
    module WithTmpDirectory
      private

      def make_tmp_directory
        Pathname(Dir.mktmpdir).tap do |dir|
          (@made_tmp_dirs ||= []) << dir
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::Support::Files
  config.include RSpec::Support::WithTmpDirectory

  config.after :all do
    if instance_variable_defined?(:@made_tmp_dirs)
      Array(@made_tmp_dirs).each do |dir|
        FileUtils.remove_entry dir
      end
    end
  end
end
