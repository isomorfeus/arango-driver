module Arango
  module Requests
    module Collection
      class Truncate < Arango::Request
        request_method :put

        uri_template "/_api/collection/{name}/truncate"

        code 200, :success
        code 400, "Collection name is missing!"
        code 404, "Collection is unknown!"
      end
    end
  end
end
