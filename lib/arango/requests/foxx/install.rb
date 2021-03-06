module Arango
  module Requests
    module Foxx
      class Install < Arango::Request
        request_method :post

        uri_template '{/dbcontext}/_api/foxx/service'

        param :development
        param :legacy
        param :mount, :required
        param :setup

        # TODO
        # body is zip, js, json, form-data

        code 201, :success
      end
    end
  end
end
