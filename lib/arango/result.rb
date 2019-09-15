module Arango
  class Result
    def initialize(result)
      @result = result ? result : {}
      @is_array = @result.class == Array
    end

    attr_accessor :response_code

    # standard fields
    def code
      @result[:code]
    end

    def error
      @result[:error]
    end

    def error_message
      @result[:errorMessage]
    end
    alias errorMessage error_message

    def error_num
      @result[:errorNum]
    end
    alias errorNum error_num

    # access to all other fields
    def [](field_name_or_index)
      return @result[field_name_or_index] if @is_array
      field_name_y = field_name_or_index.to_sym
      return @result[field_name_y] if @result.key?(field_name_y)
      field_name_s = field_name_or_index.to_s
      field_name_lcy = field_name_s.camelize(:lower).to_sym
      return @result[field_name_lcy] if @result.key?(field_name_lcy)
      field_name_ucy = field_name_s.camelize(:upper).to_sym
      return @result[field_name_ucy] if @result.key?(field_name_ucy)
      nil
    end

    def []=(field_name_or_index, value)
      return @result[field_name_or_index] = value if @is_array
      field_name_y = field_name_or_index.to_sym
      return @result[field_name_y] = value if @result.key?(field_name_y)
      field_name_s = field_name_or_index.to_s
      field_name_lcy = field_name_s.camelize(:lower).to_sym
      return @result[field_name_lcy] = value if @result.key?(field_name_lcy)
      field_name_ucy = field_name_s.camelize(:upper).to_sym
      return @result[field_name_ucy] = value if @result.key?(field_name_ucy)
      nil
    end

    def method_missing(field_name_or_index, *args, &block)
      return self[field_name_or_index] = args[0] if field_name_or_index.to_s.end_with?('=')
      return self[field_name_or_index] if field_name_or_index.class == Integer
      return self[field_name_or_index] if key?(field_name_or_index)
      @result.send(field_name_or_index, *args, &block)
    end

    # convenience
    def delete_if(*args, &block)
      @result.delete_if(*args, &block)
    end

    def empty?
      @result.empty?
    end

    def first
      @result.first
    end

    def is_array?
      @is_array
    end

    def key?(key)
      return false if @is_array
      field_name_y = key.to_sym
      return true if @result.key?(field_name_y)
      field_name_s = key.to_s
      field_name_lcy = field_name_s.camelize(:lower).to_sym
      return true if @result.key?(field_name_lcy)
      field_name_ucy = field_name_s.camelize(:upper).to_sym
      return true if @result.key?(field_name_ucy)
      false
    end
    alias has_key? key?

    def map(*args, &block)
      @result.map(*args, &block)
    end

    def raw_result
      @result
    end

    def to_underscored_h
      hash = to_h
      hash.transform_keys { |k| k.to_s.underscore }
    end

    def to_h
      return @result unless @is_array
      @result.to_h
    end
    alias to_hash to_h

    def to_a
      return @result if @is_array
      @result.to_a
    end

    def to_ary
      return @result.to_ary if @is_array
      to_a
    end

    def to_s
      @result.to_s
    end
  end
end
