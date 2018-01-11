class Kbase::RestrictionSection < Kbase::SchedRecord
  establish_connection :kbase42222
  self.table_name = 'restrictionsection'
  self.primary_keys = 'schedversionid','restrictionid','idx'
  default_scope { where( "restrictionsection.schedversionid = #{Kbase::SchedRecord.schedversionid}") }
 
  attribute :schedversionid, :integer
  attribute :restrictionid, :integer
  attribute :idx, :integer
  attribute :restrictionimpacttypeid, :integer
  attribute :odttimespanpoolid, :integer
  attribute :sectionid, :integer
  attribute :kmbegin, :integer
  attribute :kmend, :integer

  belongs_to :restriction,
    :class_name => 'Kbase::Restriction',
    :foreign_key => ['schedversionid','restrictionid']
  
  belongs_to :section,
    :class_name => 'Kbase::Section',
    :foreign_key => 'sectionid'
  
  belongs_to :odttimespanpool,
    :class_name => 'Kbase::OdtTimeSpanPool',
    :foreign_key => 'odttimespanpoolid'
  
  has_many :odttimespanpoolrefs,
    :through => :odttimespanpool

  has_many :odttimespan,
    :through => :odttimespanpoolrefs
  
  has_many :opdaytmpl,
    :through => :odttimespan

  has_many :odtcalendars,
    :through => :opdaytmpl
  
  def self.test1(limit = 10)
    for rs in Kbase::RestrictionSection.take(limit)
      ts = rs.odttimespan
      cals = rs.odtcalendars
      puts 'ts ' + ts.length.to_s
      puts 'cals ' + cals.length.to_s
    end
    true
  end
  
  def edges
    kmregid = self.section.kmregionid
    kmbegin = (self.kmbegin <= self.kmend ? self.kmbegin : self.kmend)
    kmend = (self.kmbegin <= self.kmend ? self.kmend : self.kmbegin)
    result = []
    edges = Kbase::SectionEdge.where(sectionid: self[:sectionid]).order('infraversionid,sectionid,idx asc')
    for edge in edges
      # on ne charge pas tous les nodes dans Gnode donc find_or_load
      gsn = Gnode.find_or_load(edge[:startnode])
      gen = Gnode.find_or_load(edge[:endnode])
      debugger unless gsn and gen
      res =  nil
      if kmbegin <= gsn.km(kmregid) and gsn.km(kmregid) <= kmend
        res = edge
      end
      if kmbegin <= gen.km(kmregid) and gen.km(kmregid) <= kmend
        res = edge
      end
      result << res unless res.nil?
    end
    # uniq! returns nil if no change which is not good
    #nodes.uniq
    result
  end
  
#  def becomes(klass)
#      became = klass.new
#      became.instance_variable_set("@attributes", @attributes)
#      changed_attributes = @changed_attributes if defined?(@changed_attributes)
#      became.instance_variable_set("@changed_attributes", changed_attributes || {})
#      became.instance_variable_set("@new_record", new_record?)
#      became.instance_variable_set("@destroyed", destroyed?)
#      became.instance_variable_set("@errors", errors)
#      became
#  end
  
=begin

 rs = Kbase::RestrictionSection.where(restrictionid: 788881, idx: 3).take
 Kbase::RestrictionSection.test

 reload!
 rs = Kbase::RestrictionSection.second

 zrs = rs.becomes(Kbase::ZrestrictionSection)

 rs1 = rs.odttimespanpool
 rs2 = rs1.odttimespanpoolrefs
 odt = rs2.first.odttimespan
 tmpl = odt.opdaytmpl
 dates = tmpl.odtcalendars

 ts = rs.odttimespan
 cals = rs.odtcalendars

=end 
  
end
