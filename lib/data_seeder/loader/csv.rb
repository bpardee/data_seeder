require 'csv'

module DataSeeder
  module Loader
    class CSV
      include Loader

      attr_reader :line_number

      def load(io)
        @line_number = 0
        ::CSV.foreach(io, headers: true) do |row|
          @line_number += 1
          save(row.to_hash)
        end
      end
    end
  end
end
