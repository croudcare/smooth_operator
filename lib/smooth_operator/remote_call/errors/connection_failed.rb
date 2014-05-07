module SmoothOperator
  module RemoteCall
    module Errors

      class ConnectionFailed < Base

        def initialize(response)
          @response = response
          @http_status = 0
        end

      end

    end
  end
end
