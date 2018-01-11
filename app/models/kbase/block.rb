class Kbase::Block < Kbase::InfraRecord
  establish_connection :kbase42222
  self.table_name = 'block'
  self.primary_keys = 'infraversionid','id'
  default_scope { where( "block.infraversionid = #{Kbase::InfraRecord.infraversionid}") }
  
  attribute :infraversionid, :integer
  attribute :id, :integer
  
  has_many :blocknodes,
    :class_name => 'Kbase::BlockNode',
    :foreign_key => ['infraversionid','blockid']
  
end

