class Kbase::Track < Kbase::InfraRecord
  establish_connection :kbase42222
  self.table_name = 'track'
  self.primary_keys = :infraversionid, :stationtrackid
  default_scope { where( "track.infraversionid = #{Kbase::InfraRecord.infraversionid}") }
  
  attribute :infraversionid, :integer
  attribute :stationtrackid, :integer
  
  belongs_to :stationtrack,
    class_name: 'Kbase::StationTrack',
    foreign_key: 'stationtrackid'

  has_one :tracknode, -> { where "tracknode.infraversionid = #{Kbase::InfraRecord.infraversionid} AND tracknode.seq = 0"},
    class_name: 'Kbase::TrackNode',
    foreign_key: ['infraversionid', 'stationtrackid']
 
  has_many :tracknodes, -> { where "tracknode.infraversionid = #{Kbase::InfraRecord.infraversionid}" },
    class_name: 'Kbase::TrackNode',
    foreign_key: ['tracknode.infraversionid', 'stationtrackid']
  
=begin
tr = Kbase::Track.first
str = tr.stationtrack
st = str.station
trs = st.track
tr.tracknodes
=end
  
end
