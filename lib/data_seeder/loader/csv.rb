require 'csv'

module DataSeeder
  module Loader
    class CSV
      include Loader

      attr_reader :line_number

      def load(io)
        @line_number = 0
        csv = ::CSV.new(io, headers: true)
        csv.each do |row|
          @line_number += 1
          save(row.to_hash)
        end
      end
    end
  end
end
