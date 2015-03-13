require 'json'

module DataSeeder
  module Loader
    class JSON
      include Loader
      def load(io)
        json = ::JSON.parse(io.read)
        Array(json).each do |attr|
          save(attr)
        end
      end
    end
  end
end
