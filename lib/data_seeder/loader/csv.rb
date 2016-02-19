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
          begin
            @line_number += 1
            save(row.to_hash)
          rescue Exception => e
            # TODO: Consider counting the header in the line_number count, but anyone using
            # config[:use_line_number_as_id] would have all there id's incremented
            logger.error "Exception at line #{@line_number+1}: #{e.message}"
            raise unless config[:continue_on_exception]
          end
        end
      end
    end
  end
end
