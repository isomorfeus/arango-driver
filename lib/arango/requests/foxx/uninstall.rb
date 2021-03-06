module Arango
  module Requests
    module Foxx
      class Uninstall < Arango::Request
        request_method :delete

        uri_template '{/dbcontext}/_api/foxx'

        param :mount, :required
        param :teardown

        code 204, :success
      end
    end
  end
end
