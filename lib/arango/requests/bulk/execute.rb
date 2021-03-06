module Arango
  module Requests
    module Bulk
      class Execute < Arango::Request
        request_method :post

        uri_template "/_api/batch"

        # TODO
        # body_is_string

        code 200, :success
        code 400, "Batch envelope malformed or incorrectly formatted!"
        code 405, "Invalid HTTP method!"
      end
    end
  end
end
