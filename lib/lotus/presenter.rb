module Lotus
  module Presenter
    def initialize(object)
      @object = object
    end

    protected
    def method_missing(m, *args, &blk)
      if @object.respond_to?(m)
        @object.__send__ m, *args, &blk
      else
        super
      end
    end
  end
end
