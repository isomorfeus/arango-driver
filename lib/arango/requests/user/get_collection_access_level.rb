module Arango
  module Requests
    module User
      class GetCollectionAccessLevel < Arango::Request
        request_method :get

        uri_template '{/dbcontext}/_api/user/{user}/database/{database}/{collection}'

        code 200, :success
        code 400, "Wrong access privileges!"
        code 401, "No database access to the _system database!"
        code 403, "No server access!"
      end
    end
  end
end
