class Tsection < ApplicationRecord
  establish_connection :tps_db
  self.table_name = 'sections'

  has_many stationtracks
end
