module Arango
  module Requests
    module Graph
      class DeleteVertex < Arango::Request
        request_method :delete

        uri_template '{/dbcontext}/_api/gharial/{graph}/vertex/{collection}/{vertex}'

        header 'if-match'

        param :return_old
        param :wait_for_sync

        code 200, :success
        code 202, :success
        code 403, "Permission denied!"
        code 404, "Graph or collection or vertex could not be found!"
        code 412, "Revision mismatch!"
      end
    end
  end
end
