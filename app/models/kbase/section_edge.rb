class Kbase::SectionEdge < Kbase::InfraRecord
  establish_connection :kbase42222
  self.table_name = 'sectionedge'
  self.primary_keys = 'infraversionid','sectionid','idx'
  default_scope { where( "sectionedge.infraversionid = #{Kbase::InfraRecord.infraversionid}") }

  attribute :infraversionid, :integer
  attribute :sectionid, :integer
  attribute :idx, :integer
  attribute :startnode, :integer
  attribute :endnode, :integer  
  
  belongs_to :section,
    :class_name => 'Kbase::Section',
    :foreign_key => 'sectionid'

  belongs_to :startnode,
    :class_name => 'Kbase::Node',
    :foreign_key => ['infraversionid','startnode']

  belongs_to :endnode,
    :class_name => 'Kbase::Node',
    :foreign_key => ['infraversionid','endnode']
  
=begin

=end
  
end
