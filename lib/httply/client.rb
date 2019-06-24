module Httply
  class Client
    attr_accessor :host, :configuration
    attr_accessor :memoize, :connection
    
    include ::Httply::Proxies
    
    def initialize(host: nil, configuration: ::Httply.configuration, memoize: false)
      self.host             =   correct_host(host)
      self.configuration    =   configuration
      self.memoize          =   memoize
      self.connection       =   nil
    end
    
    def setup(host: host, headers: headers, options: options)
      self.connection       =   configure(host: host, headers: headers, options: options)
    end
    
    def get(path, parameters: {}, headers: {}, options: {})
      request path, method: :get, parameters: parameters, headers: headers, options: options
    end
    
    def head(path, parameters: {}, headers: {}, options: {})
      request path, method: :head, parameters: parameters, headers: headers, options: options
    end

    def post(path, parameters: {}, data: {}, headers: {}, options: {})
      request path, method: :post, parameters: parameters, data: data, headers: headers, options: options
    end
    
    def put(path, parameters: {}, data: {}, headers: {}, options: {})
      request path, method: :put, parameters: parameters, data: data, headers: headers, options: options
    end
    
    def patch(path, parameters: {}, data: {}, headers: {}, options: {})
      request path, method: :patch, parameters: parameters, data: data, headers: headers, options: options
    end
    
    def delete(path, parameters: {}, data: {}, headers: {}, options: {})
      request path, method: :delete, parameters: parameters, data: data, headers: headers, options: options
    end
    
    def request(path, method: :get, parameters: {}, data: {}, headers: {}, options: {})
      host                      =   parse_host(path)
      path                      =   to_path(path)
      connection                =   nil
      
      if self.memoize
        self.connection       ||=   configure(host: host, headers: headers, options: options)
        connection              =   self.connection
      else
        connection              =   configure(host: host, headers: headers, options: options)
      end
  
      response                  =   case method
        when :get
          connection.get do |request|
            request.url path
            request.params      =   parameters if parameters && !parameters.empty?
          end
        when :head
          connection.head do |request|
            request.url path
            request.params      =   parameters if parameters && !parameters.empty?
          end
        when :post, :put, :patch, :delete
          connection.send(method) do |request|
            request.url path
            request.body        =   data if data && !data.empty?
            request.params      =   parameters if parameters && !parameters.empty?
          end
      end
      
      return response
    end
    
    def configure(host:, headers: {}, options: {})
      client_options            =   options.fetch(:client, {})
      
      request_options           =   options.fetch(:request, {})
      redirects                 =   request_options.fetch(:redirects, 10)
      
      proxy                     =   determine_proxy(options.fetch(:proxy, nil))
      
      headers["User-Agent"]     =   headers.fetch("User-Agent", ::Agents.random_user_agent(options.fetch(:user_agent_device, :desktop)))
      
      connection                =   ::Faraday.new(host, client_options) do |builder|
        builder.options[:timeout]         =   options.fetch(:timeout, nil)      if options.fetch(:timeout, nil)
        builder.options[:open_timeout]    =   options.fetch(:open_timeout, nil) if options.fetch(:open_timeout, nil)
        
        builder.headers         =   headers
        
        builder.request  :url_encoded if request_options.fetch(:url_encoded, false)
        builder.request  :json        if request_options.fetch(:json, false)
        
        builder.response :logger      if self.configuration.verbose
        builder.response :xml,  content_type: /\bxml$/
        builder.response :json, content_type: /\bjson$/
        builder.use ::Httply::Middlewares::ParseHtml, content_type: /\btext\/html$/
        
        builder.use ::FaradayMiddleware::FollowRedirects, limit: redirects if redirects && redirects > 0
        
        if proxy
          builder.proxy         =   generate_faraday_proxy(proxy)
          log("Will use proxy: #{builder.proxy.inspect}")
        end
    
        builder.adapter self.configuration.faraday.fetch(:adapter, ::Faraday.default_adapter)
      end
      
      return connection
    end
    
    def log(message)
      puts "[Httply::Client] - #{message}" if self.configuration.verbose
    end
    
    def correct_host(host)
      if !host.to_s.empty?
        host                    =   host =~ /^http(s)?:\/\//i ? host : "https://#{host}"
      end
    end
    
    def parse_host(url)
      host                      =   !self.host.to_s.empty? ? self.host : nil
      
      if host.to_s.empty? && url =~ /^http(s)?:\/\//
        uri                     =   URI(url)
        host                    =   "#{uri.scheme}://#{uri.host}"
      end
      
      return host
    end
    
    def to_path(path)
      if path =~ /^http(s)?:\/\//
        path                    =   URI(path).path
      end
      
      path                      =   path =~ /^\// ? path : "/#{path}"
      
      return path
    end
    
  end
end
