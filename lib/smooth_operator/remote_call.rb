module SmoothOperator

  module RemoteCall

    class Base

      extend Forwardable

      attr_reader :response

      def initialize(response)
        @response = response
      end

      def_delegators :response, :success?, :status, :headers, :body

      
      def error?
        !success?
      end

      def data
        require 'json' unless defined?(::JSON)

        begin
          JSON.parse(body)
        rescue JSON::ParserError
          nil
        end
      end

    end

    class ConnectionFailed

      attr_reader :data, :status, :headers, :body

      def status; 0; end

      def error?; true; end

      def success?; false; end

    end

  end

end