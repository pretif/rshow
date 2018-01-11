class Tsth < ApplicationRecord
  establish_connection :tps_db
  self.table_name = 'sths'
  self.primary_key = 'gid'

#  def self.find_or_create(sth)
#    aux = GisSth.find :first, :conditions => ["stationid = ?", sth[:id]]
#    unless aux
#      if sth.xcoord
#        aux = GisSth.new :stationid => sth[:id],
#          :the_geom => GeoRuby::SimpleFeatures::Point.from_x_y(sth.xcoord / (1852.0 * 60.0), sth.ycoord / (1852.0 * -60.0), 2192),
#          :name => sth.name.rstrip
#        aux.save!
#      end
#    end
#    aux
#  end

end