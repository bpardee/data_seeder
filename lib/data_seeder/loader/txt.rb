module DataSeeder
  module Loader
    class Txt
      include Loader

      def load(io)
        if method = config[:line]
          io.each_line do |line|
            next if line.blank? || line.match(/^\s*#/)
            save(method.call(line))
          end
        else
          raise "No line method defined for #{self.klass.name}"
        end
      end
    end
  end
end
