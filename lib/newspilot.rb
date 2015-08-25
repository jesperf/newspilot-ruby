require_relative 'newspilot/version'
require_relative 'newspilot/configuration'
require_relative 'newspilot/client'
require_relative 'newspilot/utils'
require_relative 'newspilot/resources'

module Newspilot
  @client = nil

  class << self
    attr_accessor :client
    attr_accessor :config
    attr_accessor :configuration

    def client
      @client = Newspilot::Client.new
    end

    def get(*args)
      client.get(*args)
    end

    # def post(*args, &block)
    #   self.client.post *args
    # end
    #
    # def put(*args, &block)
    #   self.client.put *args
    # end

    def get_jpeg(*args)
      client.get_jpeg(*args)
    end
  end

  def self.configure
    @configuration = Configuration.new
    yield(configuration)
  end
end

require 'newspilot/resources'
