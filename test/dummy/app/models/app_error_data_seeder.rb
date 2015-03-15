require 'data_seeder'

class AppErrorDataSeeder
  include ::DataSeeder::Loader

  def setup
    @app = App.find_or_initialize_by(name: self.path_minus_ext)
    @existing_errors = {}
    if @app.new_record?
      logger.info "Loading errors for new App: #{@app.name}"
      @app.save!
    else
      logger.info "Loading errors for existing App: #{@app.name}"
      @app.app_errors.each do |app_error|
        @existing_errors[app_error.code] = app_error
      end
    end
  end

  def teardown
    unless @existing_errors.empty?
      logger.info { "  The following are begin removed:" }
      @existing_errors.each do |code, app_error|
        logger.info "    #{code}: #{app_error.message}"
        app_error.destroy
      end
    end
  end

  def load(io)
    io.each_line do |line|
      line.strip!
      next if line.blank? || line[0] == ?#
      space_i   = line.index(' ')
      raise "Invalid line: #{line}" unless space_i
      code      = line[0,space_i].strip
      message   = line[space_i+1..-1].strip
      app_error = @existing_errors[code]
      if app_error
        @existing_reason_codes.delete(code)
        app_error.message = message
        unless app_error.changes.empty?
          logger.info { "  Changing #{code}: #{app_error.changes}" }
          app_error.save!
        end
      else
        logger.info { "  Creating #{code}: #{message}" }
        @app.app_errors.create!(code: code, message: message)
      end
    end
  end
end
