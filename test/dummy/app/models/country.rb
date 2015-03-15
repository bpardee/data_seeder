class Country < ActiveRecord::Base
  def self.data_seeder_line(line)
    {
      code: line[0,2],
      name: line[3...-1],
    }
  end

  def self.data_seeder_config
    {
      key_attribute: :code
    }
  end
end
