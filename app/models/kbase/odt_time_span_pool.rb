class Kbase::OdtTimeSpanPool < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'odttimespanpool'
  self.primary_key = 'id'

  attribute :id, :integer
  
  has_many :odttimespanpoolrefs,
    :class_name => 'Kbase::OdtTimeSpanPoolRef',
    :foreign_key => "odttimespanpoolid"

  has_many :odttimespan,
    :through => :odttimespanpoolrefs
  
  has_many :opdaytmpl,
    :through => :odttimespan

  has_many :odtcalendars,
    :through => :opdaytmpl

=begin

odt = Kbase::OdtTimeSpanPool.find(346179)
odt.odttimespan
odt.odtcalendars

odt.odttimespan.first.odtcalendars
odt.odttimespan.second.odtcalendars
odt.odttimespan.third.odtcalendars

=end
end

