module Arango
  module Requests
    module Foxx
      class EnableDevelopmentMode < Arango::Request
        request_method :enable

        uri_template '{/dbcontext}/_api/foxx/development'

        param :mount, :required

        code 200, :success
      end
    end
  end
end
