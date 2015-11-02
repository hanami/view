# Base view error
#
# This is a base error used to produce Lotus view errors.
#
# Allows better rescue options than simply catching `StandardError`.
#
# @since 0.4.4
module Lotus
  module View
    class Error < ::StandardError
    end
  end
end
