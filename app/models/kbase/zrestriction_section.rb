class Kbase::ZrestrictionSection < Kbase::SchedRecord
  establish_connection :kbase42222
  self.table_name = 'zrestrictionsection'
  self.primary_keys = 'infraversionid','schedversionid','restrictionid','idx'
  default_scope { where( "zrestrictionsection.schedversionid = #{Kbase::SchedRecord.schedversionid} and zrestrictionsection.infraversionid = #{Kbase::InfraRecord.infraversionid}") }
 
  attribute :infraversionid, :integer
  attribute :schedversionid, :integer
  attribute :restrictionid, :integer
  attribute :idx, :integer
  attribute :restrictionimpacttypeid, :integer
  attribute :odttimespanpoolid, :integer
  attribute :sectionid, :integer
  attribute :kmbegin, :integer
  attribute :kmend, :integer

  @@factory = RGeo::Cartesian.factory(srid: 2192)
  
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
   
  
  def self.load(infraversionid = Kbase::InfraRecord.infraversionid, schedversionid = Kbase::SchedRecord.schedversionid)
    Kbase::ZrestrictionSection.where(infraversionid: infraversionid,schedversionid: schedversionid).delete_all
    Gnode.load_in_cache(infraversionid)
    rss = Kbase::RestrictionSection.includes(:section).where(schedversionid: schedversionid)
    for rs in rss
      #unless Kbase::ZrestrictionSection.where(infraversionid: infraversionid,schedversionid: schedversionid,restrictionid: rs[:restrictionid], idx: rs[:idx]).exists?
        if rs.section
          zrs = Kbase::ZrestrictionSection.new(rs.attributes)
          zrs.infraversionid = infraversionid
          # on a parfois  des odttimespanpool inexistant !
          zrs.save(validate: false)
          # Reste à mettre à jour zrs.the_geom 
=begin 
le pb est qu'il faut fusionner les arêtes
faire un truc dans le genre

update section set the_geom = (select st_setsrid(st_linemerge(st_collect(se.the_geom)),2192)
	from (select sectionedge.the_geom
		       from sectionedge
	  where infraversionid = 2822 and sectionedge.sectionid = section.id) as se) where sectiontypeid = 1 and the_geom is null;
=end
          idxs = rs.edges.collect {|ed| ed.idx}
          sql1 = Kbase::SectionEdge.select("the_geom").where(infraversionid: infraversionid, sectionid: rs.section.id, idx: idxs).to_sql
          sql = " update zrestrictionsection set the_geom = (select st_setsrid(st_linemerge(st_collect(se.the_geom)),2192) from (#{sql1}) as se) where infraversionid = #{infraversionid} and schedversionid = #{schedversionid} and restrictionid = #{rs[:restrictionid]} and idx = #{rs[:idx]}"
          Kbase::ZrestrictionSection.connection.execute(sql)
        end
      #end #unless
    end
    sql = "SELECT refresh_zmatview('ZRESTRICTION_MV')"
    Kbase::ZrestrictionSection.connection.execute(sql)
  end
  
  
=begin
,'schedversionid','restrictionid',
 Kbase::RestrictionSection.test

 reload!
 Kbase::ZrestrictionSection.load

 rs = Kbase::RestrictionSection.second
 

 rs1 = rs.odttimespanpool
 rs2 = rs1.odttimespanpoolrefs
 odt = rs2.first.odttimespan
 tmpl = odt.opdaytmpl
 dates = tmpl.odtcalendars

 ts = rs.odttimespan
 cals = rs.odtcalendars

=end 
  
end
