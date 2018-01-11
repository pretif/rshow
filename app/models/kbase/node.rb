class Kbase::Node < Kbase::InfraRecord
  establish_connection :kbase42222
  self.table_name = 'node'
  self.primary_keys = 'infraversionid','id'
  default_scope { where( "node.infraversionid = #{Kbase::InfraRecord.infraversionid}") }
  
  attribute :infraversionid, :integer
  attribute :id, :integer

#  has_many :tracknodes, #-> { where "infraversionid = #{Kbase::InfraRecord.infraversionid}"},
#    :class_name => 'Kbase::TrackNode',
#    :foreign_key => ['infraversionid','node']

  def tracknodes
    Kbase::TrackNode.where("tracknode.infraversionid = #{self.infraversionid} AND tracknode.node = #{self[:id]}" )
  end
  
  def tracknode
    Kbase::TrackNode.where("tracknode.infraversionid = #{self.infraversionid} AND tracknode.node = #{self[:id]} ANS seq = 0" )
  end
  
  has_many :blocknodes,
    :class_name => 'Kbase::BlockNode',
    :foreign_key => ['infraversionid','node']
  
  def km(kmregid)
    if self.kmregionid == kmregid
      return self.kmvalue
    elsif
      self.secondkmregionid == kmregid
      return self.secondkmvalue
    else
      return nil
    end
    nil
  end
  
=begin
trn = Kbase::TrackNode.first
nd = trn.node
trn = nd.tracknodes
trn.gnode

knodes = Kbase::Node.select("id, xcoord, ycoord, kmvalue, kmregionid, secondkmvalue, secondkmregionid")
knodes.length   
198461

knodes = Kbase::Node.joins(:blocknodes).select("id, xcoord, ycoord, kmvalue, kmregionid, secondkmvalue, secondkmregionid").distinct
knodes.length
192468

=end

end

