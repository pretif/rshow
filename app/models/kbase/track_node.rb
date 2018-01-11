class Kbase::TrackNode < Kbase::InfraRecord
  establish_connection :kbase42222
  self.table_name = 'tracknode'
  self.primary_keys = 'infraversionid','stationtrackid','seq'
  default_scope { where( "tracknode.infraversionid = #{Kbase::InfraRecord.infraversionid}") }
  
  attribute :infraversionid, :integer
  attribute :stationtrackid, :integer
  attribute :seq, :integer
  attribute :node, :integer

#  def track
#    @track ||= Kbase::Track.where("infraversionid = #{Kbase::InfraRecord.infraversionid} AND stationtrackid = #{self.stationtrackid} ").first
#  end

  belongs_to :track, -> { where "track.infraversionid = #{Kbase::InfraRecord.infraversionid}"},
    :class_name => 'Kbase::Track',
    :foreign_key => ['infraversionid','stationtrackid']

  belongs_to :node, -> { where "node.infraversionid = #{Kbase::InfraRecord.infraversionid}"},
    :class_name => 'Kbase::Node',
    :foreign_key => ['infraversionid','node']
  
#  has_one :stationtrack, through: :track
    
#  def node
#    @node ||= Kbase::Node.where("infraversionid = #{Kbase::InfraRecord.infraversionid} AND id = #{self[:node]}").first
#  end

  def gnode
    Gnode.find(self[:node])
  end

=begin
trn = Kbase::TrackNode.first
trn.node
trn.gnode
tr = trn.track
tr = Kbase::Track.first
str = tr.stationtrack
st = str.station
trs = st.track
tr.tracknodes
=end

end
