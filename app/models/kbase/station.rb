class Kbase::Station < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'stationheader'

  #set_rgeo_factory_for_column(:the_geom, RGeo::Cartesian.factory(:srid => 2192))
  
  has_many :stationtracks,
    :class_name => 'Kbase::StationTrack',
    :foreign_key => 'stationid'

  has_many :tracks, -> { where "track.infraversionid = #{Kbase::InfraRecord.infraversionid}"},
    :through => :stationtracks
  
  has_many :tracknodes, {:through=>:tracks, :source=>"tracknode"}

  attribute :id, :integer
  
  @@factory = RGeo::Cartesian.factory(srid: 2192)
  
  def make_point
    x = 0.0 ; y = 0.0 ; n = 0.0
    if self.stationtracks
      for node in self.tracknodes
        if node.the_geom
          n += 1
          x += node.the_geom.x
          y += node.the_geom.y
        end
      end
      self.the_geom = @@factory.point(x/n,y/n)
      self.save!
    end
  end
  
  def xcoord
    self.the_geom.x
  end
  
  def ycoord
    self.the_geom.y
  end
  
  def self.place_stations
    Kbase::Station.find_each do |sth|
      sth.make_point
    end
  end
 
  def self.find_by_lat_lon(lat,lon)
   sql = "SELECT kbase.stationheader.id, name as display_name, stationabbrev,the_geom, ST_X(the_geom) as lat, ST_Y(the_geom) as lon, left(stationabbrev, strpos(stationabbrev, '/')-1) as CI, rtrim(right(stationabbrev, -1*strpos(stationabbrev, '/'))) as CH,
the_geom <-> st_setsrid(st_makepoint(#{lat},#{lon}), 2192) as dist FROM kbase.stationheader
where (rtrim(right(stationabbrev, -1*strpos(stationabbrev, '/'))) = 'BV' OR
      rtrim(right(stationabbrev, -1*strpos(stationabbrev, '/'))) = '00' )
ORDER BY the_geom <-> st_setsrid(st_makepoint(#{lat},#{lon}), 2192)
LIMIT 1;"
    sths = Kbase::Station.find_by_sql sql
    for sth in sths
      sth.display_name = sth.display_name.rstrip + ' ' + sth.ci + '/' + sth.ch
    end
    sths
  end

  def self.geosearch(q,limit)
    res = Kbase::Station.select('id,name,stationabbrev,ST_X(stationheader.the_geom) as stx, ST_Y(stationheader.the_geom) as sty').where("name LIKE '#{q}%' AND ST_X(stationheader.the_geom) IS NOT NULL").limit(limit)
    vect = []
    for re in res
      vect << { :"place_id" => re.id,
:"lat" => re.stx,
:"lon" => re.sty,
:"display_name" => re.name.rstrip + " " + re.stationabbrev.rstrip,        
      }
    end
    vect
  end

=begin

  Kbase::Station.place_stations

  sth = Kbase::Station.where("stationabbrev LIKE '547026/BV%'").take
  Galgorithm.load_in_cache
  sth.tracknodes.collect {|tn| tn.gnode} 

  sth.make_point
 
SELECT name, id, left(stationabbrev, strpos(stationabbrev, '/')-1) as CI, right(stationabbrev, strpos(stationabbrev, '/')) as CH
FROM kbase.stationheader
ORDER BY the_geom <-> st_setsrid(st_makepoint(47525,-32755), 2192)
LIMIT 10;

=end
  
end
