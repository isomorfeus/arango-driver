module Arango
  module Requests
    module Replication
      class DeleteDumpBatch < Arango::Request
        request_method :delete

        uri_template '{/dbcontext}/_api/replication/batch/{id}'

        code 204, :success
        code 400, "Ttl value is invalid!"
        code 405, "Invalid HTTP request method!"
      end
    end
  end
end
