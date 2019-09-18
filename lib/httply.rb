require "faraday"
require "faraday_middleware"
require "agents"

require "uri"

require "httply/version"
require "httply/configuration"

require "httply/middlewares/html"

require "httply/utilities/uri"

require "httply/proxies"
require "httply/client"

module Httply
  class Error < StandardError; end
  
  class << self
    attr_writer :configuration
    
    def configuration
      @configuration ||= ::Httply::Configuration.new
    end

    def reset
      @configuration = ::Httply::Configuration.new
    end

    def configure
      yield(configuration)
    end
    
    [:get, :head, :post, :put, :patch, :delete].each do |http_verb|
      define_method(http_verb) do |path, *args|
        args    =   args.any? ? args.flatten.first : nil
        ::Httply::Client.new.send(http_verb, path)
      end
    end
    
  end
end
