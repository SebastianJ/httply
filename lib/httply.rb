require "faraday"
require "faraday_middleware"
require "agents"

require "httply/version"
require "httply/configuration"

module Httply
  class Error < StandardError; end
  
  class << self
    attr_writer :configuration
  end
  
  def self.configuration
    @configuration ||= ::Httply::Configuration.new
  end

  def self.reset
    @configuration = ::Httply::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
  
end

require "httply/middlewares/html"

require "httply/proxies"
require "httply/client"
