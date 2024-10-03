module JSONAPI
  Response = Struct.new(:data, :pagination, keyword_init: true)
end
