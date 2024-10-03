module JSONAPI
end

Dir["#{File.dirname(__FILE__)}/jsonapi/**/*.rb"].each { |f| require f }
