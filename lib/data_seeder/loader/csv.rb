require 'csv'

module DataSeeder
  module Loader
    class CSV
      include Loader

      def load(io)
        ::CSV.foreach(io, headers: true) do |row|
          save(row.to_hash)
        end
      end
    end
  end
end
