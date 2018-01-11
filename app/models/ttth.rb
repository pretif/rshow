class Ttth < ApplicationRecord
  establish_connection :tps_db
  self.table_name = 'dwh_a50_tth'
  
end
