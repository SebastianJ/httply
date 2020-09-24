module Httply
  class Client
    attr_accessor :host, :configuration
    attr_accessor :memoize, :connection
    
    include ::Httply::Proxies
    
    def initialize(host: nil, configuration: ::Httply.configuration, memoize: false)
      self.host             =   ::Httply::Utilities::Uri.correct_host(host)
      self.configuration    =   configuration
      self.memoize          =   memoize
      self.connection       =   nil
    end
    
    def setup(host: nil, headers: {}, options: {})
      self.connection     ||=   configure(host: host, headers: headers, options: options)
    end
    
    def get(path, parameters: {}, headers: {}, options: {}, format: nil)
      request path, method: :get, parameters: parameters, headers: headers, options: options, format: format
    end
    
    def head(path, parameters: {}, headers: {}, options: {}, format: nil)
      request path, method: :head, parameters: parameters, headers: headers, options: options, format: format
    end

    def post(path, parameters: {}, data: {}, headers: {}, options: {}, format: nil)
      request path, method: :post, parameters: parameters, data: data, headers: headers, options: options, format: format
    end
    
    def put(path, parameters: {}, data: {}, headers: {}, options: {}, format: nil)
      request path, method: :put, parameters: parameters, data: data, headers: headers, options: options, format: format
    end
    
    def patch(path, parameters: {}, data: {}, headers: {}, options: {}, format: nil)
      request path, method: :patch, parameters: parameters, data: data, headers: headers, options: options, format: format
    end
    
    def delete(path, parameters: {}, data: {}, headers: {}, options: {}, format: nil)
      request path, method: :delete, parameters: parameters, data: data, headers: headers, options: options, format: format
    end
    
    def request(path, method: :get, parameters: {}, data: {}, headers: {}, options: {}, format: nil)
      host                      =   !self.host.to_s.empty? ? self.host : ::Httply::Utilities::Uri.parse_host(path)
      path                      =   ::Httply::Utilities::Uri.to_path(path)
      connection                =   self.memoize ? setup(host: host, headers: headers, options: options) : configure(host: host, headers: headers, options: options)
  
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
      
      response                  =   force_format(response, format) unless format.to_s.empty?
      
      return response
    end
    
    def force_format(response, format)
      case format.to_sym
        when :json
          response.body         =   ::JSON.parse(response.body)
        when :xml
          response.body         =   ::MultiXml.parse(response.body)
        when :html
          response.body         =   ::Nokogiri::HTML(response.body, nil, "utf-8")
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
        builder.response :xml,      content_type: /\bxml$/
        builder.response :json,     content_type: /\bjson$/
        builder.use ::Httply::Middlewares::ParseHtml, content_type: /\btext\/html$/
        
        builder.use ::FaradayMiddleware::FollowRedirects, limit: redirects if redirects && redirects > 0
        
        if proxy && !proxy.empty?
          builder.proxy         =   proxy
          log("Will use proxy: #{builder.proxy.inspect}")
        end
    
        builder.adapter self.configuration.faraday.fetch(:adapter, ::Faraday.default_adapter)
      end
      
      return connection
    end
    
    def log(message)
      puts "[Httply::Client] - #{message}" if self.configuration.verbose
    end
    
  end
end
