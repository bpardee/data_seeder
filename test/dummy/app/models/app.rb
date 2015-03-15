class App < ActiveRecord::Base
  has_many :app_errors, inverse_of: :app
end
