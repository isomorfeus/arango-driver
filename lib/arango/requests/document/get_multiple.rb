module Arango
  module Requests
    module Document
      class GetMultiple < Arango::Request
        request_method :put

        uri_template '{/dbcontext}/_api/document/{collection}#get'

        param :onlyget, :required
        param :ignore_revs

        code 200, :success
        code 400, "Body does not contain a valid JSON representation of an array of documents!"
        code 404, "Collection not found!"
      end
    end
  end
end
