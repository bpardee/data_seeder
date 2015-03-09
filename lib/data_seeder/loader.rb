module DataSeeder
  module Loader
    attr_accessor :klass, :file_config
    attr_reader   :path, :path_minus_ext

    def initialize(options={})
      @only = options[:only]
      @except = options[:except]
      if options.has_key?(:purge)
        @purge = options[:purge]
      else
        @purge = true
      end
      @old_ids = []
    end

    def config
      DataSeeder.config
    end

    def logger
      DataSeeder.logger
    end

    def load(path)
      @path           = path
      dot_index       = @path.rindex('.')
      @path_minus_ext = @path[0, dot_index]
      @file_config    = {}
      setup
      load_file
      teardown
      call_file_method(:teardown)
    end

    def setup
      @klass = @path_minus_ext.classify.constantize
      @old_ids = @klass.all.pluck(:id) if @purge
      logger.info { "Loading #{@klass.table_name}" }
    end

    def teardown
      @old_ids.each do |id|
        model = @klass.find(id)
        logger.info { "  Destroying #{model_info(model)}"}
        model.destroy
      end
    end

    # The information displayed when creating, updating, or destroying a model.
    # The changes argument will be the model.changes on an update.
    def model_info(model, changes=nil)
      if changes
        attr = @file_config[:update_display_method] || :id
        "#{model.send(attr)}: #{changes.inspect}"
      else
        model.inspect
      end
    end

    def load_file
      File.open(@path, 'r') do |fin|
        load_file_config(fin)
        load_io(fin)
      end
    end

    def load_file_config(fin)
      config_line = fin.readline
      fin.seek(0)
      if match = config_line.match(/^\s*#\s*config:(.*)/)
        @file_config = eval(match[1])
      end
      # We need to do this here instead of setup so we can have the file_config filled
      call_file_method(:setup)
    end

    def load_io(fin)
      throw 'Must override load_io or load_file'
    end

    def save(attr)
      id = (attr['id'] || attr[:id]).try(:to_i)
      raise "No id in #{attr.inspect}" unless id
      @old_ids.delete(id)
      model = @klass.find_by(id: id) || @klass.new(id: id)
      model.attributes = attr
      save_model(model)
    end

    def save_model(model)
      if model.new_record?
        logger.info { "  Saving #{model_info(model)}" }
      else
        changes = model.changes
        return if changes.empty?
        logger.info { "  Updating #{model_info(model, changes)}" }
      end
      model.save!
    end

    def call_file_method(name, *args)
      if method = @file_config[name]
        return method.call(*args)
      else
        class_method = "data_seeder_#{name}"
        return @klass.send(class_method, *args) if @klass.respond_to?(class_method)
      end
      return nil
    end
  end
end

#require 'data_seeder/loader/csv'
require 'data_seeder/loader/json'
require 'data_seeder/loader/yaml'
require 'data_seeder/loader/txt'
