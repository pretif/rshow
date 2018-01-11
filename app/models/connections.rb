# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

class GisConnect < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :postgis
end

class Kbase42222Connect < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :postgis
end