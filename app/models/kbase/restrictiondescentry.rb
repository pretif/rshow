class Kbase::Restrictiondescentry < Kbase::SchedRecord
  establish_connection :kbase42222
  self.table_name = 'restrictiondescentry'
  self.primary_keys = 'schedversionid','restrictionid', 'seq'
  default_scope { where( "restrictiondescentry.schedversionid = #{Kbase::SchedRecord.schedversionid} and restrictiondescentry.seq = 0") }
  # Dans l'horaire 601, il n'y a pas de seq > 0
 
  attribute :schedversionid, :integer
  attribute :restrictionid, :integer
  attribute :seq, :integer 
  
  belongs_to :restriction,
    :class_name => 'Kbase::Restriction',
    :foreign_key => ['schedversionid','restrictionid']
  
end
