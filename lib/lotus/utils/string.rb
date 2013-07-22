module Lotus
  module Utils
    class String < ::String
      def underscore
        self.
          gsub('::', '/').
          gsub(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          downcase
      end
    end
  end
end
