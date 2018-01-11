class Kbase::Restriction < Kbase::SchedRecord
  establish_connection :kbase42222
  self.table_name = 'restriction'
  self.primary_keys = 'schedversionid','id'
  default_scope { where( "restriction.schedversionid = #{Kbase::SchedRecord.schedversionid}") }
 
  attribute :schedversionid, :integer
  attribute :id, :integer
  attribute :restrictiontypeid, :integer
  attribute :restrictionstateid, :integer # 0 unset, 1 import, 2 validated, 3 effective, 4 cancelled, 5 completed

  has_many :restrictionsections,
    :class_name => 'Kbase::RestrictionSection',
    :foreign_key => ['schedversionid','restrictionid']

  has_many :restrictiondescentries,
    :class_name => 'Kbase::Restrictiondescentry',
    :foreign_key => ['schedversionid','restrictionid']
  
  def comment
    aux = self.restrictiondescentries
    aux.nil? ? "" : aux.first.text
  end
  
=begin

tst = Kbase::Restriction.where(id: 515121).take
tst1 = tst.restrictionsections
tst2 = tst.restrictionsections.first
tst3 = tst2.restriction
tst3 = tst2.section

tst.restrictiondescentries
tst.comment

=end
  
end
