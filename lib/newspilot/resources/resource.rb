require File.expand_path('../../utils', __FILE__)
require 'json'

module Newspilot
  module Resource
    attr_accessor :attributes
    attr_accessor :id
    attr_accessor :headers

    def initialize(attributes = {}, headers = {})
      @attributes = attributes
      @headers = headers
    end

    def id
      (attributes['id'] ||= nil)
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def etag
      headers['etag']
    end

    def method_missing(method, *args, &_block)
      return @attributes[method.to_s] if @attributes.key?(method.to_s)
      return @attributes[method.to_s.camelize(:lower)] if @attributes.key?(method.to_s.camelize(:lower))

      case method.to_s
      when /(.+)=$/
        attribute = method.to_s.chop
        if @attributes.key?(attribute)
          puts "attribute: #{@attributes[attribute]}"
          @attributes[attribute] = args[0]
        elsif @attributes.key?(attribute.camelize(:lower))
          @attributes[attribute.camelize(:lower)] = args[0]
        end

      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @attributes.key?(method.to_s) || @attributes.key?(method.to_s.camelize(:lower)) || super
    end

    def save
      begin
        @response = Newspilot.put(etag, href, self.sanitize)
        @headers = @response.headers
      rescue
        # restore the href on the instance if there was an exception
        # this will allow us to try to fix any attributes and save again
        raise
      end
    end

    def sanitize
      JSON.generate(@attributes)
    end

    def href
      self.class.collection_with_id(id)
    end

    module ClassMethods
      def construct_from_response(payload, headers)
        resource_body = if payload.size > 2
                          payload
                        else
                          payload[1].first
                        end unless payload.empty?
        resource_body.delete('link') if resource_body
        new (resource_body) ? resource_body : {}, headers
      end

      def find(id)
        response = Newspilot.get(collection_with_id(id))
        construct_from_response JSON.parse(response.body), response.headers
      end

      def where(options = {})
        options = preprocess_options(options)
        response = Newspilot.get collection_name, options
        json_response = JSON.parse(response.body)
        json_response.first[1].map { |attributes| construct_from_response attributes, response.headers }
      end

      alias_method :all, :where

      # private

      def resource_name
        Utils.demodulize name
      end

      def collection_name
        Utils.pluralize Utils.camelize_lower(resource_name)
      end

      def collection_with_id(id)
        "#{collection_name}/#{id}"
      end

      def preprocess_options(options)
        options = options.merge(query_depts) if Newspilot.configuration.departments?
        [:photoDate, :prodDate].each do |date_param|
          options[date_param] = date_range_parse(options[date_param]) if options[date_param]
        end
        options = updated_after(options) if options[:updated_after]
        options
      end

      # add departments from the configuration to the query
      def query_depts
        { 'respDepartment' => Newspilot.configuration.departments }
      end

      def updated_after(options)
        updated_after = options.delete(:updated_after)
        return options unless updated_after.is_a?(Time)
        updated_range = updated_after.strftime('%Y-%m-%dT%H:%M:%S.%L%:z') + ' TO ' +
                        (updated_after + 2.years).strftime('%Y-%m-%dT%H:%M:%S.%L%:z')
        options.merge(updatedDate: updated_range)
      end

      def date_range_parse(date_range)
        return unless date_range.is_a?(Range)
        #a = date_range.to_a
        a = date_range
        return if !a.begin.is_a?(Date) && !a.end.is_a?(Date)

        "#{a.begin.strftime('%Y-%m-%d')} TO " \
          "#{a.end.strftime('%Y-%m-%d')}"
      end
    end
  end
end
