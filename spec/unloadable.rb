# frozen_string_literal: true

module Unloadable
  def unload!
    self.configuration = configuration.duplicate
    configuration.unload!
  end
end
