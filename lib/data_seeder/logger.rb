module DataSeeder
  class Logger < ::Logger
    attr_accessor :verbose

    def initialize
      super($stdout)
      @verbose = true
      self.formatter = ->(severity, datetime, progname, msg) { "#{msg}\n" }
    end

    def info(arg='', &block)
      super if @verbose
    end
  end
end
