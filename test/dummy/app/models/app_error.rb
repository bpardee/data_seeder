class AppError < ActiveRecord::Base
  belongs_to :app, inverse_of: :app_errors
end
