class Kbase::BlockNode < Kbase::InfraRecord
  establish_connection :kbase42222
  self.table_name = 'blocknode'
  self.primary_keys = 'infraversionid','blockid','seq'
  default_scope { where( "blocknode.infraversionid = #{Kbase::InfraRecord.infraversionid}") }
  
  attribute :infraversionid, :integer
  attribute :blockid, :integer
  attribute :seq, :integer
  attribute :node, :integer
  
  belongs_to :block,
    :class_name => 'Kbase::Block',
    :foreign_key => ['infraversionid','blockid']
  
  belongs_to :_node,
    :class_name => 'Kbase::Node',
    :foreign_key => ['infraversionid','node']

=begin
bn = Kbase::BlockNode.first
nd = bn._node
bns = nd.blocknodes

=end
end

