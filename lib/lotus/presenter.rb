module Lotus
  # Presenter pattern implementation
  #
  # @since 0.1.0
  #
  # @example
  #   require 'lotus/view'
  #
  #   class Map
  #     attr_reader :locations
  #
  #     def initialize(locations)
  #       @locations = locations
  #     end
  #
  #     def location_names
  #       @locations.join(', ')
  #     end
  #   end
  #
  #   class MapPresenter
  #     include Lotus::Presenter
  #
  #     def count
  #       locations.count
  #     end
  #
  #     def location_names
  #       super.upcase
  #     end
  #
  #     def inspect_object
  #       @object.inspect
  #     end
  #   end
  #
  #   map = Map.new(['Rome', 'Boston'])
  #   presenter = MapPresenter.new(map)
  #
  #   # access a map method
  #   puts presenter.locations # => ['Rome', 'Boston']
  #
  #   # access presenter concrete methods
  #   puts presenter.count # => 1
  #
  #   # uses super to access original object implementation
  #   puts presenter.location_names # => 'ROME, BOSTON'
  #
  #   # it has private access to the original object
  #   puts presenter.inspect_object # => #<Map:0x007fdeada0b2f0 @locations=["Rome", "Boston"]>
  module Presenter
    # Initialize the presenter
    #
    # @param object [Object] the object to present
    #
    # @since 0.1.0
    def initialize(object)
      @object = object
    end

    protected
    # Override Ruby's method_missing
    #
    # @api private
    # @since 0.1.0
    def method_missing(m, *args, &blk)
      if @object.respond_to?(m)
        @object.__send__ m, *args, &blk
      else
        super
      end
    end

    # Override Ruby's respond_to_missing? in order to support proper delegation
    #
    # @api private
    # @since 0.3.0
    def respond_to_missing?(m, include_private = false)
      @object.respond_to?(m, include_private)
    end
  end
end
