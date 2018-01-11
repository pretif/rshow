class Kbase::AttributeSection < Kbase::InfraRecord
  establish_connection :kbase42222
  self.table_name = 'attributesection'
  self.primary_keys = 'infraversionid','sectionid'
  default_scope { where( "attributesection.infraversionid = #{Kbase::InfraRecord.infraversionid}") }
  
  attribute :infraversionid, :integer
  attribute :sectionid, :integer
  attribute :kmregionid, :integer
  
  belongs_to :section,
    :class_name => 'Kbase::Section',
    :foreign_key => 'sectionid'

=begin

=end
  
end
