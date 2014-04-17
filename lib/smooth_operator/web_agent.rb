require 'faraday'
# require 'faraday_middleware'
# require 'typhoeus'
# require 'typhoeus/adapters/faraday'

module SmoothOperator

  module WebAgent

    HTTP_VERBS = [:get, :post, :put, :delete]

    OPTIONS = [:endpoint, :endpoint_user, :endpoint_pass, :timeout]


    attr_writer *OPTIONS

    OPTIONS.each { |option| define_method(option) { get_option(option) } }

    HTTP_VERBS.each { |http_verb| define_method(http_verb) { |relative_path = '', params = {}, options = {}| make_the_call(http_verb, relative_path, params, options) } }


    def generate_parallel_connection
      generate_connection(:typhoeus)
    end

    def generate_connection(adapter = :net_http)
      Faraday.new(url: endpoint) do |faraday|
        faraday.adapter  adapter
        faraday.request  :url_encoded
      end
    end


    protected ################ PROTECTED ################

    def make_the_call(http_verb, relative_path = '', params = {}, options = {})
      connection, options = strip_options(options)

      begin
        response = connection.send(http_verb) do |request|
          request.url relative_path
          params.each { |key, value| request.params[key] = value }
          options.each { |key, value| request.options.send("#{key}=", value) }
        end

        RemoteCall::Base.new(response)
        
      rescue Faraday::ConnectionFailed
        RemoteCall::ConnectionFailed.new
      end
    end


    private ################# PRIVATE ###################

    def strip_options(options)
      options ||= {}

      options[:timeout] ||= timeout unless timeout == ''
      connection = (options.delete(:connection) || generate_connection)

      [connection, options]
    end

    def get_option(option)
      instance_var = instance_variable_get("@#{option}")

      return instance_var unless instance_var.nil?

      (zuper_method(option) || ENV["API_#{option.upcase}"] || '').dup.tap do |instance_var|
        instance_variable_set("@#{option}", instance_var)
      end
    end

  end

end