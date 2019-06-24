module Httply
  module Utilities
    class Uri
      class << self
        
        def correct_host(host)
          if !host.to_s.empty?
            host                    =   host =~ /^http(s)?:\/\//i ? host : "https://#{host}"
          end
      
          return host
        end
    
        def parse_host(url)
          host                      =   nil
      
          if host.to_s.empty? && url =~ /^http(s)?:\/\//
            uri                     =   URI(url)
            host                    =   "#{uri.scheme}://#{uri.host}"
          end
      
          return host
        end
    
        def to_path(path)
          path                      =   path =~ /^http(s)?:\/\// ? URI(path).path : path
          path                      =   path =~ /^\// ? path : "/#{path}"
        end
        
      end
    end
  end
end
