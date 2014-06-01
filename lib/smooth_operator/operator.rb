require "smooth_operator/remote_call/base"
require "smooth_operator/operators/faraday"
require "smooth_operator/operators/typhoeus"
require "smooth_operator/remote_call/errors/timeout"
require "smooth_operator/remote_call/errors/connection_failed"

module SmoothOperator
  module Operator

    def make_the_call(http_verb, relative_path = '', data = {}, options = {})
      options ||= {}

      relative_path = resource_path(relative_path)

      if !_parent_object.nil? && options[:ignore_parent] != true
        id = Helpers.primary_key(_parent_object)

        options[:resources_name] ||= "#{_parent_object.class.resources_name}/#{id}/#{self.class.resources_name}"
      end

      self.class.make_the_call(http_verb, relative_path, data, options) do |remote_call|
        yield(remote_call)
      end
    end

    def resource_path(relative_path)
      if Helpers.absolute_path?(relative_path)
        Helpers.remove_initial_slash(relative_path)
      elsif persisted?
        id = Helpers.primary_key(self)

        Helpers.present?(relative_path) ? "#{id}/#{relative_path}" : id.to_s
      else
        relative_path
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      OPTIONS = [:endpoint, :endpoint_user, :endpoint_pass, :timeout]

      OPTIONS.each do |option|
        define_method(option) { Helpers.get_instance_variable(self, option, '') }
      end

      attr_writer *OPTIONS

      def headers
        Helpers.get_instance_variable(self, :headers, {})
      end

      attr_writer :headers

      def make_the_call(http_verb, relative_path = '', data = {}, options = {})
        options = HelperMethods.populate_options(self, options)

        resource_path = resource_path(relative_path, options)

        params, data = *HelperMethods.strip_params(self, http_verb, data)

        operator = HelperMethods.get_me_an_operator(options)

        operator.make_the_call(http_verb, resource_path, params, data, options) do |remote_call|
          block_given? ? yield(remote_call) : remote_call
        end
      end

      def query_string(params)
        params
      end

      def resource_path(relative_path, options)
        resources_name = options[:resources_name] || self.resources_name

        if Helpers.present?(resources_name)
          Helpers.present?(relative_path) ? "#{resources_name}/#{relative_path}" : resources_name
        else
          relative_path.to_s
        end
      end

    end

    module HelperMethods

      extend self

      def get_me_an_operator(options)
        if options[:parallel_connection].nil?
          Operators::Faraday
        else
          Operators::Typhoeus
        end
      end

      def populate_options(object, options)
        options ||= {}

        ClassMethods::OPTIONS.each do |option|
          options[option] ||= object.send(option)
        end

        options[:headers] = object.headers.merge(options[:headers] || {})

        options
      end

      def strip_params(object, http_verb, data)
        data ||= {}

        if [:get, :head, :delete].include?(http_verb)
          [object.query_string(data), nil]
        else
          [object.query_string({}), data]
        end
      end

    end

  end
end
