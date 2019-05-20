module Httply
  class Configuration
    attr_accessor :verbose, :faraday
    
    def initialize
      self.verbose    =   false
      self.faraday    =   {adapter: :net_http}
    end
    
  end
end
