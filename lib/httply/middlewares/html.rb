require 'faraday_middleware/response_middleware'

module Httply
  module Middlewares
    # Public: parses response bodies with Nokogiri.
    class ParseHtml < ::FaradayMiddleware::ResponseMiddleware
      dependency 'nokogiri'

      define_parser do |body, parser_options|
        ::Nokogiri::HTML(body, nil, "utf-8")
      end
    end
  end
end

# deprecated alias
Faraday::Response::ParseHtml = Httply::Middlewares::ParseHtml
