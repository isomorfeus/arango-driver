module Arango
  module Requests
    module Replication
      class GetLoggerTickRanges < Arango::Request
        request_method :get

        uri_template '{/dbcontext}/_api/replication/logger-tick-ranges'

        code 200, :success
        code 405, "Invalid HTTP request method!"
        code 500, "A error occurred!"
      end
    end
  end
end
