module RateCenter
  module Collection
    def collection
      raise Errors::DataNotLoadedError.new("No data loaded. Load data with RateCenter.load before calling this method") if data.nil?

      @collection ||= load_collection
    end

    def reload!
      @collection = nil
    end

    def all
      collection
    end

    def find_by(attributes)
      collection.find do |region|
        attributes.all? { |key, value| region[key] == value }
      end
    end

    def find_by!(*)
      find_by(*) || raise(Errors::NotFoundError.new)
    end
  end
end
