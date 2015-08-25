require File.expand_path('../../utils', __FILE__)
require 'json'

module Newspilot
  module Resource
    attr_accessor :attributes
    attr_accessor :id

    def initialize(attributes = {})
      @attributes = attributes
    end

    def id
      (attributes['id'] ||= nil)
    end

    def self.included(base)
      base.extend ClassMethods
    end

    def method_missing(method, *_args, &_block)
      return @attributes[method.to_s] if @attributes.key?(method.to_s)
    end

    def respond_to_missing?(method_name, include_private = false)
      @attributes.key?(method.to_s) || super
    end

    module ClassMethods
      def construct_from_response(payload)
        resource_body = if payload.size > 2
                          payload
                        else
                          payload[1].first
                        end
        resource_body.delete('link')
        new resource_body
      end

      def find(id)
        response = Newspilot.get(collection_with_id(id))
        construct_from_response JSON.parse(response.body)
      end

      def where(options = {})
        options = preprocess_options(options)
        response = Newspilot.get collection_name, options
        response = JSON.parse(response.body)
        response.first[1].map { |attributes| construct_from_response attributes }
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
        options
      end

      # add departments from the configuration to the query
      def query_depts
        { 'respDepartment' => Newspilot.configuration.departments }
      end

      def date_range_parse(date_range)
        return unless date_range.is_a?(Range)
        a = date_range.to_a
        return if !a.first.is_a?(Date) && !a.last.is_a?(Date)

        "#{a.first.strftime('%Y-%m-%d')} TO " \
          "#{a.last.strftime('%Y-%m-%d')}"
      end
    end
  end
end
