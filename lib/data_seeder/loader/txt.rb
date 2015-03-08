require 'yaml'

module DataSeeder
  module Loader
    class Txt
      include Loader

      def load_io(io)
        if method = self.file_config[:line]
          io.each_line do |line|
            next if line.match(/^\s*#/)
            save(method.call(line))
          end
        elsif self.klass.respond_to?(:data_seeder_line)
          io.each_line do |line|
            next if line.match(/^\s*#/)
            save(self.klass.send(:data_seeder_line, line))
          end
        else
          raise "No line method defined for #{self.klass.name}"
        end
      end
    end
  end
end
