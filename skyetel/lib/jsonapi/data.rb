module JSONAPI
  Data = Struct.new(:id, :type, :attributes, :relationships, :links, keyword_init: true)
end
