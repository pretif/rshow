class Kbase::Section < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'section'
  self.primary_key = 'id'

  attribute :id, :integer
  attribute :sectiontypeid, :integer

  has_many :attributesections, -> { where "attributesection.infraversionid = #{Kbase::InfraRecord.infraversionid}"},
    :class_name => 'Kbase::AttributeSection',
    :foreign_key => 'sectionid'
  
  has_many :restrictionsections, -> { where "restrictionsection.schedversionid = #{Kbase::SchedRecord.schedversionid}"},
    :class_name => 'Kbase::RestrictionSection',
    :foreign_key => 'sectionid'

  has_many :sectionedges, -> { where("sectionedge.infraversionid = #{Kbase::InfraRecord.infraversionid}").order("idx asc")},
    :class_name => 'Kbase::SectionEdge',
    :foreign_key => 'sectionid'
  
  def nodes
    nodes = [self.sectionedges.first.starnode]
    for edge in self.sectionedges
      # déjà trié
      nodes << edge.endnode
    end
    nodes
  end
  
  def kmregionid
    @kmregid ||= ((aux = self.attributesections.first).nil? ? nil : aux[:kmregionid])
  end
  
=begin

tst = Kbase::Section.where(id: 783).take
edges = tst.sectionedges
secs = tst.attributesections.take
rests = tst.restrictionsections.take


=end
  
end
