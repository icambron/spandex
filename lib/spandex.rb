require 'spandex/page'
require 'spandex/finder'

module Spandex
  class << self

    def new(base_path)
      Spandex::Finder.new(base_path)
    end

    def method_missing(method, *args, &block)
      return super unless new.respond_to?(method)
      new.send(method, *args, &block)
    end

    def respond_to?(method, include_private = false)
      new.respond_to?(method, include_private) || super(method, include_private)
    end

  end
end
