module Httply
  class Response
    attr_accessor :response, :body
    
    def initialize(response)
      self.response   =   response
      self.body       =   response.body
    end
    
  end
end
