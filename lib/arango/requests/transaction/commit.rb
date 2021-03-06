module Arango
  module Requests
    module Transaction
      class Commit < Arango::Request
        request_method :put

        uri_template '{/dbcontext}/_api/transaction/{id}'

        code 200, :success
        code 400, "Transaction cannot be committed!"
        code 404, "Transaction unknown!"
        code 409, "Transaction already aborted!"
      end
    end
  end
end
