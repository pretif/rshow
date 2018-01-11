class Kbase::StationTrack < Kbase::InfraRecord
  establish_connection :kbase42222
  self.table_name = 'stationtrack'
  
  belongs_to :station,
    :class_name => 'Kbase::Station',
    :foreign_key => 'stationid'

  has_one :track, -> { where "track.infraversionid = #{Kbase::InfraRecord.infraversionid}"},
    :class_name => 'Kbase::Track',
    :foreign_key => 'stationtrackid'
  
  has_one :tracknode, through: :track
  
  attribute :id, :integer
  attribute :stationid, :integer

  def track
    @track ||= Kbase::Track.where("infraversionid = #{Kbase::InfraRecord.infraversionid} AND stationtrackid = '#{self[:id]}'").first
  end

  def gx
    self.the_geom.x.to_i
  end
  
   def gy
    self.the_geom.y.to_i
  end
  
#  def id
#    self.attributes["id"].to_i.to_s
#  end
# Kbase::StationTrack.find(:first).attributes["id"].to_i.to_s
  
  def self.geosearch(q,limit)
    res = Kbase::StationTrack.joins(:station).where("name LIKE '#{q}%'").select('stationtrack.id,nameforpublishing,abbreviation,name,stationabbrev,ST_X(stationtrack.the_geom) as stx, ST_Y(stationtrack.the_geom) as sty').limit(limit)
    vect = []
    for re in res
      vect << { :"place_id" => re.id,
:"lat" => re.stx,
:"lon" => re.sty,
:"display_name" => re.name.rstrip + ' ' + re.stationabbrev + ' ' + re.abbreviation.rstrip + '#' + re.nameforpublishing,        
      }
    end
    vect
  end
  
=begin
res = Kbase::StationTrack.search('Paris')
res = Kbase::StationTrack.joins(:station).where("name LIKE 'Paris%'").select('stationtrack.id,nameforpublishing,name,stationabbrev').limit(5)
=end

end
