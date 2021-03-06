module Arango
  module Requests
    module Analyzer
      class Create < Arango::Request
        request_method :post

        uri_template "/_api/analyzer"

        body :features
        body :name
        body :properties
        body :type

        code 200, :success
        code 201, :success
        code 400, "Parameter missing or not valid!"
        code 403, "Permission denied!"
      end
    end
  end
end
