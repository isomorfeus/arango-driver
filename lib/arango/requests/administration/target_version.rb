module Arango
  module Requests
    module Administration
      class TargetVersion < Arango::Request
        request_method :get

        uri_template "/_admin/database/target-version"

        code 200, :success
      end
    end
  end
end
