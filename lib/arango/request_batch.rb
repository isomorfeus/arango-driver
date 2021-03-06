module Arango
  class RequestBatch
    include Arango::Helper::Satisfaction

    include Arango::Helper::DatabaseAssignment
    include Arango::Helper::ServerAssignment

    # Initialize a new request batch.
    # Request must be a Hash with the keys:
    # - :id, optional
    # - :action, required
    # - :url, required
    # - :body, optional
    # @param server [Arango::Server] The server the requests should be run on. One of server or database must be given.
    # @param database [Arango::Database] The database the requests should be run on. One of server or database must be given.
    # @param requests [Array<Hash>, Hash] Array of requests or a single request as Hash, optional.
    # @return [Arango::RequestBatch]
    def initialize(server: nil, database: nil, requests: [])
      @id = 1
      if database
        assign_database(database)
      elsif server
        assign_server(server)
      else
        raise Arango::Error.new(err: :server_or_database_must_be_given)
      end
      send(:requests=, requests)
      @boundary = "ArangoDriverRequestPart"
      @headers = { 'Content-Type' => "multipart/form-data; boundary=#{@boundary}" }
    end

    attr_reader :database, :requests, :server

    # Assign a bunch of requests.
    # @param requests [Array<Hash>, Hash] Array of requests or a single request as Hash, optional.
    # @return [Array<Hash>]
    def requests=(requests)
      requests = [requests] unless requests.is_a?(Array)
      @requests = {}
      requests.each do |request|
        add_request(**request)
      end
      return @requests
    end

    # Add a single request
    # @param id [String] optional
    # @param action [String]
    # @param url [String]
    # @param body [Hash] optional
    def add_request(get: nil, head: nil, patch: nil, post: nil, put: nil, delete: nil, body: nil, query: nil, headers: nil, block: nil, promise: nil)
      id = @id.to_s
      @id += 1
      @requests[id] = {
        id:     id,
        body:   body,
        query:  query,
        block: block,
        headers: headers,
        promise: promise
      }.delete_if{|_,v| v.nil?}
      @requests[id][:action] = if get then @requests[id][:url] = get; 'GET'
                               elsif head then @requests[id][:url] = head; 'HEAD'
                               elsif patch then @requests[id][:url] = patch; 'PATCH'
                               elsif post then @requests[id][:url] = post; 'POST'
                               elsif put then @requests[id][:url] = put; 'PUT'
                               elsif delete then @requests[id][:url] = delete; 'DELETE'
                               end
      @requests[id]
    end
    alias modify_request add_request

    def delete_request(id)
      @requests.delete(id)
      @requests
    end

    # Execute the request batch.
    # @return [Hash<Arango::Result]
    def execute
      body = ""
      @requests.each do |id, request|
        body << "--#{@boundary}\r\n"
        body << "Content-Type: application/x-arango-batchpart\r\n"
        body << "Content-Id: #{id}\r\n\r\n"
        url = "/#{request[:url]}"
        if request.key?(:query)
          url << '?'
          url << URI.encode_www_form(request[:query])
        end
        body << "#{request[:action]} #{url} HTTP/1.1\r\n"
        if request.key?(:headers)
          request[:headers].each do |header, value|
            body << "#{header}: #{value}\r\n"
          end
        end
        body << "\r\n"
        unless request[:body].nil?
          request[:body].delete_if{|_,v| v.nil?}
          body << "#{Oj.dump(request[:body], mode: :json)}\r\n"
        end
      end
      body << "--#{@boundary}--\r\n\r\n" if @requests.length > 0
      raise 'empty batch request' if body.empty?
      result = if @database
                 @database.request(post: '_api/batch', body: body, headers: @headers)
               else
                 @server.request(post: '_api/batch', body: body, headers: @headers)
               end
      result_hash = _parse_result(result)
      _check_for_errors(result_hash)
      final_result = result_hash
      result_hash.each_key do |id|
        request = @requests[id.to_s]
        if request.key?(:block)
          result = result_hash[id]
          if request.key?(:promise)
            block_result = request[:block].call(result)
            final_result = request[:promise].resolve(block_result)
          else
            final_result = request[:block].call(result)
          end
        end
      end
      final_result
    end

    private

    def _check_for_errors(result_hash)
      result_hash.each do |k, result|
        if !result.is_array? && result.error?
          raise Arango::ErrorDB.new(message: result.error_message, code: result.response_code, data: result.to_h, error_num: result.error_num,
                                    action: '', url: '', request: { request_part: k })
        end
      end
      result_hash
    end

    def _parse_result(result)
      parts = result.split("--#{@boundary}")
      result_hash = {}
      parts.each do |part|
        if part == "" || part == "--"
          false
        else
          key = nil
          is_json = false
          body = nil
          code = 0
          lines = part.split("\r\n")
          lines.each do |line|
            if line.start_with?('Content-Id: ')
              key = line[12..-1]
            elsif line.start_with?('HTTP/1.1 ')
              code = line[9..12].to_i
            elsif line.start_with?('Content-Type: application/json')
              is_json = true
            elsif line.start_with?('{') || line.start_with?('[')
              if is_json
                body = Oj.load(line, mode: :json, smybol_keys: true)
              else
                body = line
              end
            end
          end
          res = Arango::Result.new(is_json ? body : { body: body })
          res.response_code = code
          result_hash[key.to_sym] = res
        end
      end
      result_hash
    end
  end
end
