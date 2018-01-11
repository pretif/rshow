class Kbase::OpDayType < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'opdaytype'
  self.primary_keys = 'id'

  attribute :id, :integer

end
