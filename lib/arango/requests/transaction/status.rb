module Arango
  module Requests
    module Transaction
      class Status < Arango::Request
        request_method :get

        uri_template '{/dbcontext}/_api/transaction/{id}'

        code 200, :success
        code 400, "Transaction identifier missing or malformed!"
        code 404, "Transaction unknown!"
      end
    end
  end
end
