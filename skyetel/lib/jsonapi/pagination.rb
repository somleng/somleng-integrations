module JSONAPI
  Pagination = Struct.new(:prev, :next, keyword_init: true)
end
