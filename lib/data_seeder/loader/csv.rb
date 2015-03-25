require 'csv'

module DataSeeder
  module Loader
    class CSV
      include Loader

      def line_number
        # Don't count the header
        $INPUT_LINE_NUMBER-1
      end

      def load(io)
        ::CSV.foreach(io, headers: true) do |row|
          save(row.to_hash)
        end
      end
    end
  end
end
