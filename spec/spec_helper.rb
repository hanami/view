# frozen_string_literal: true

require "pathname"
TEMPLATE_ROOT_DIRECTORY = Pathname.new(__dir__).join("support", "fixtures", "templates")

$LOAD_PATH.unshift "lib"
require "hanami/utils"
require "hanami/devtools/unit"
require "hanami/view"

Hanami::Utils.require!("spec/support")
