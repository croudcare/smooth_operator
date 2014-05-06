require 'typhoeus'

module SmoothOperator

  module OperatorCall

    class Typhoeus < Base

      def make_the_call
        begin
          set_basic_authentication

          response = connection.send(http_verb) do |request|
            operator_options.each { |key, value| request.options.send("#{key}=", value) }
            options[:headers].each { |key, value| request.headers[key] = value }
            params.each { |key, value| request.params[key] = value }

            request.url relative_path
            request.body = body
          end

          RemoteCall::Base.new(response)
        rescue ::Faraday::Error::ConnectionFailed
          RemoteCall::Errors::ConnectionFailed.new(response)
        rescue ::Faraday::Error::TimeoutError
          RemoteCall::Errors::Timeout.new(response)
        end
      end


      protected ################ PROTECTED ################

      def set_basic_authentication
        connection.basic_auth(endpoint_user, endpoint_pass) if Helpers.present?(endpoint_user)
      end

    end

  end
end
