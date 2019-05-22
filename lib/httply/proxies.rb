module Httply
  module Proxies
    
    def determine_proxy(options)
      proxy                         =   nil
      
      if options
        proxy                     ||=   {}
        
        if options.is_a?(String)
          proxy                     =   proxy_from_string(options, proxy)
          
        elsif options.is_a?(Hash) && !options.empty?
          proxy                     =   proxy_from_hash(options, proxy)
        
        elsif options.is_a?(Array) && options.any?
          proxy                     =   proxy_from_array(options, proxy)
          
        elsif proxy_model_defined? && options.is_a?(::Proxy)
          proxy                     =   proxy_from_object(options, proxy)
        end
      end
      
      return proxy
    end
    
    def proxy_from_string(options, proxy)
      options                       =   options.gsub(/^http(s)?:\/\//i, "")
      parts                         =   options.split(":")

      if parts.size.eql?(2)
        proxy[:host]                =   parts.first
        proxy[:port]                =   parts.second.to_i
      end
      
      return proxy
    end
    
    def proxy_from_hash(options, proxy)
      host                          =   options.fetch(:host, nil)
      port                          =   options.fetch(:port, nil)
      
      username                      =   options.fetch(:username, nil)
      password                      =   options.fetch(:password, nil)
      
      randomize                     =   options.fetch(:randomize, true)
      type                          =   options.fetch(:type, :all)
      protocol                      =   options.fetch(:protocol, :all)
      
      if randomize && proxy_model_defined?
        proxy_object                =   ::Proxy.get_random_proxy(protocol: protocol, proxy_type: type)
        proxy                       =   proxy_from_object(proxy_object, proxy)
      else
        if host && port
          proxy[:host]              =   host
          proxy[:port]              =   port
          
          proxy                     =   set_credentials(username, password, proxy)
        end
      end
      
      return proxy
    end
    
    def proxy_from_array(options)
      item                          =   options.sample
      
      if item.is_a?(String)
        proxy                       =   proxy_from_string(item, proxy)
      elsif item.is_a?(Hash) && !item.empty?
        proxy                       =   proxy_from_hash(item, proxy)
      elsif proxy_model_defined? && item.is_a?(::Proxy)
        proxy                       =   proxy_from_object(item, proxy)
      end
      
      return proxy
    end
    
    def proxy_from_object(proxy_object, proxy)
      if proxy_object
        proxy[:host]                =   proxy_object.host
        proxy[:port]                =   proxy_object.port
        username                    =   !proxy_object.username.to_s.empty? ? proxy_object.username : nil
        password                    =   !proxy_object.password.to_s.empty? ? proxy_object.password : nil
        
        proxy                       =   set_credentials(username, password, proxy)
      end
      
      return proxy
    end

    def set_credentials(username, password, proxy)
      proxy[:username]              =   username unless username.to_s.empty?
      proxy[:password]              =   password unless password.to_s.empty?
      
      return proxy
    end
    
    def proxy_model_defined?
      defined                       =   Module.const_get("Proxy").is_a?(Class) rescue false
      defined                       =   (defined && ::Proxy.respond_to?(:get_random_proxy))
      
      return defined
    end
    
    def generate_faraday_proxy(proxy)
      proxy_options                 =   {}
      
      if proxy && !proxy[:host].to_s.empty? && !proxy[:port].to_s.empty?
        proxy_options[:uri]         =   "http://#{proxy[:host]}:#{proxy[:port]}"
        proxy_options[:user]        =   proxy[:username] unless proxy[:username].to_s.empty?
        proxy_options[:password]    =   proxy[:password] unless proxy[:password].to_s.empty?
      end
      
      return proxy_options
    end
    
  end
end
