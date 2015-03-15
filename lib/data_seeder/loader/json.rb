require 'json'

module DataSeeder
  module Loader
    class JSON
      include Loader
      def load(io)
        json = ::JSON.parse(io.read)
        if json.kind_of?(Hash)
          json.each do |key, attr|
            attr[self.key_attribute] = key if self.key_attribute
            save(attr)
          end
        else
          Array(json).each { |attr| save(attr) }
        end
      end
    end
  end
end
