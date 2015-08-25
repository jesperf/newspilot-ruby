module Newspilot
  class Configuration
    attr_accessor :username, :password, :departments, :scheme,
                  :host, :prefix, :port, :version

    def departments?
      @departments.is_a?(Array) && !@departments.empty? &&
        @departments.all? { |d| d.is_a?(Integer) }
    end

    # defaults
    def initialize
      @departments = []
      @version = '1.0'
      @scheme = 'http'
      @host = 'localhost'
      @prefix = 'webservice'
      @port = 8080
    end
  end
end
