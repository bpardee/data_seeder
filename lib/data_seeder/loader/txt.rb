module DataSeeder
  module Loader
    class Txt
      include Loader

      attr_reader :line_number

      def load(io)
        if method = config[:line]
          @line_number = 0
          io.each_line do |line|
            begin
              @line_number += 1
              next if line.blank? || line.match(/^\s*#/)
              save(method.call(line))
            rescue Exception => e
              logger.error "Exception at line #{@line_number}: #{e.message}"
              raise unless config[:continue_on_exception]
            end
          end
        else
          raise "No line method defined for #{self.klass.name}"
        end
      end
    end
  end
end
