module Httply
  class Client
    attr_accessor :host, :configuration
    
    include ::Httply::Proxies
    
    def initialize(host: nil, configuration: ::Httply.configuration)
      self.host             =   host
      self.configuration    =   configuration
    end
    
    def to_uri(path)
      path                  =   path.gsub(/^\//i, "")
      
      if path !~ /^http(s)?:\/\// && !self.host.to_s.empty?
        host_part           =   self.host =~ /^http(s)?:\/\// ? self.host : "https://#{self.host}"
        path                =   "#{host_part}/#{path}"
      end
      
      return path
    end
    
    def get(path, parameters: {}, headers: {}, options: {}, as: nil)
      request path, method: :get, parameters: parameters, headers: headers, options: options, as: as
    end
    
    def head(path, parameters: {}, headers: {}, options: {}, as: nil)
      request path, method: :head, parameters: parameters, headers: headers, options: options, as: as
    end

    def post(path, parameters: {}, data: {}, headers: {}, options: {}, as: nil)
      request path, method: :post, parameters: parameters, data: data, headers: headers, options: options, as: as
    end
    
    def put(path, parameters: {}, data: {}, headers: {}, options: {}, as: nil)
      request path, method: :put, parameters: parameters, data: data, headers: headers, options: options, as: as
    end
    
    def patch(path, parameters: {}, data: {}, headers: {}, options: {}, as: nil)
      request path, method: :patch, parameters: parameters, data: data, headers: headers, options: options, as: as
    end
    
    def delete(path, parameters: {}, data: {}, headers: {}, options: {}, as: nil)
      request path, method: :delete, parameters: parameters, data: data, headers: headers, options: options, as: as
    end
    
    def request(path, method: :get, parameters: {}, data: {}, headers: {}, options: {}, as: nil)
      connection                =   setup(path, headers: headers, options: options, as: as)
  
      response                  =   case method
        when :get
          connection.get do |request|
            request.parameters  =   parameters if parameters && !parameters.empty?
          end
        when :head
          connection.head do |request|
            request.parameters  =   parameters if parameters && !parameters.empty?
          end
        when :post, :put, :patch, :delete
          connection.send(method) do |request|
            request.body        =   data if data && !data.empty?
            request.parameters  =   parameters if parameters && !parameters.empty?
          end
      end
      
      return response
    end
    
    def setup(path, headers: {}, options: {}, as: nil)
      client_options            =   options.fetch(:client, {})
      follow_redirects          =   options.fetch(:follow_redirects, false)
      redirect_limit            =   options.fetch(:redirects_limit, 10)
      proxy                     =   determine_proxy(options.fetch(:proxy, nil))
      
      url                       =   to_uri(path)
      
      headers                   =   {"User-Agent" => ::Agents.random_user_agent(options.fetch(:user_agent_device, :desktop))}.merge(headers)
      
      connection                =   ::Faraday.new(url, client_options) do |builder|
        builder.options[:timeout]         =   options.fetch(:timeout, nil)      if options.fetch(:timeout, nil)
        builder.options[:open_timeout]    =   options.fetch(:open_timeout, nil) if options.fetch(:open_timeout, nil)
        
        builder.headers         =   headers
        
        builder.response :logger if self.configuration.verbose
        
        builder.response :xml,  content_type: /\bxml$/  if as.eql?(:xml)
        builder.response :json, content_type: /\bjson$/ if as.eql?(:json)
        builder.use ::Httply::Middlewares::ParseHtml      if as.eql?(:html)
        
        builder.use ::FaradayMiddleware::FollowRedirects, limit: redirect_limit if follow_redirects && redirect_limit && redirect_limit > 0
        
        if proxy
          builder.proxy         =   generate_faraday_proxy(proxy)
          puts "[Httply::Client] - Will use proxy: #{builder.proxy.inspect}" if self.configuration.verbose
        end
    
        builder.adapter self.configuration.faraday.fetch(:adapter, ::Faraday.default_adapter)
      end
      
      return connection
    end
    
  end
end
