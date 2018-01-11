class Gtrack < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'track'
  self.primary_keys = :infraversionid, :stationtrackid
  
  attribute :infraversionid, :integer
  attribute :stationtrackid, :integer
  
  belongs_to :stationtrack,
    class_name: 'Kbase::StationTrack',
    foreign_key: 'stationtrackid'
  
  has_one :tracknode, -> { where 'seq = 0'},
    class_name: 'Kbase::TrackNode',
    foreign_key: ['infraversionid', 'stationtrackid']
 
end
