require 'logger'
require 'uri'
require 'faraday'
require 'faraday_middleware'
require 'active_support/all'
require 'faraday/detailed_logger/middleware'

module Newspilot
  # heavily inspired by https://github.com/balanced/balanced-ruby/
  # thanks!
  class Client
    CONNECTION_SETTINGS = {
      logging_level: 'WARN',
      connection_timeout: 60,
      read_timeout: 60,
      logger: nil,
      ssl_verify: true,
      faraday_adapter: Faraday.default_adapter,
      accept_type: 'application/json'
    }

    attr_reader :conn
    attr_accessor :config

    def initialize(config = Newspilot.configuration)
      @config = config
      build_conn
    end

    def build_conn
      if CONNECTION_SETTINGS[:logger]
        logger = CONNECTION_SETTINGS[:logger]
      else
        logger = Logger.new(STDOUT)
        logger.level = Logger.const_get(CONNECTION_SETTINGS[:logging_level].to_s)
      end

      options = {
        request: {
          open_timeout: CONNECTION_SETTINGS[:connection_timeout],
          timeout: CONNECTION_SETTINGS[:read_timeout]
        },
        ssl: {
          verify: CONNECTION_SETTINGS[:ssl_verify] # Only set this to false for testing
        }
      }
      @conn = Faraday.new(url, options) do |cxn|
        # cxn.request :json
        cxn.response :logger, logger
        cxn.response :detailed_logger #, Rails.logger if defined?(Rails) && Rails.env.development?
        # cxn.response :json
        cxn.response :raise_error  # raise exceptions on 40x, 50x responses
        cxn.adapter CONNECTION_SETTINGS[:faraday_adapter]
        cxn.options.params_encoder = Faraday::FlatParamsEncoder
      end
      conn.path_prefix = "/#{config.prefix}"
      conn.headers['User-Agent'] = "newspilot-ruby/#{Newspilot::VERSION}"
    end

    def url
      builder = (config.scheme == 'http') ? URI::HTTP : URI::HTTPS
      builder.build(host: config.host, port: config.port,
                    scheme: config.scheme)
    end

    def get(*args)
      conn.headers['Content-Type'] = 'application/json'
      conn.headers['Accept'] = "#{CONNECTION_SETTINGS[:accept_type]}"
      conn.basic_auth(config.username, config.password)
      conn.get(*args)
    end

    def get_jpeg(*args)
      conn.headers['Accept'] = 'image/jpeg'
      conn.basic_auth(config.username, config.password)
      conn.get(*args)
    end
    
    def put(etag, *args)
      conn.headers['Content-Type'] = 'application/json'
      conn.headers['Accept'] = "#{CONNECTION_SETTINGS[:accept_type]}"
      conn.headers['If-Match'] = etag
      conn.basic_auth(config.username, config.password)
      conn.put(*args)
    end

    # def method_missing(method, *args, &block)
    #   if is_http_method? method
    #     conn.basic_auth(username, password)
    #     conn.send method, *args
    #   else
    #     super method, *args, &block
    #   end
    # end
    #
    # private
    #
    # def http_method?(method)
    #   [:get, :post, :put, :delete].include? method
    # end
    #
    # def respond_to?(method, include_private = false)
    #   if http_method? method
    #     true
    #   else
    #     super method, include_private
    #   end
    # end
  end
end
