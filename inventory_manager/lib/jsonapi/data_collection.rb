module JSONAPI
  class DataCollection
    attr_reader :collection, :pagination

    def initialize(data, pagination: nil)
      @collection = data
      @pagination = pagination
    end

    def auto_paging_each(&)
      return enum_for(:auto_paging_each) unless block_given?

      if pagination
        each(&)
        pagination.next.fetch.data.auto_paging_each(&)
      else
        each(&)
      end
    end

    def each(...)
      collection.each(...)
    end

    def size
      collection.size
    end

    def map(...)
      collection.map(...)
    end
  end
end
