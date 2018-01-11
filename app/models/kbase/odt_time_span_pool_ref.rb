class Kbase::OdtTimeSpanPoolRef < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'odttimespanpoolref'
  self.primary_keys = 'odttimespanpoolid', 'odttimespanid'

  attribute :odttimespanpoolid, :integer
  attribute :odttimespanid, :integer
  
  belongs_to :odttimespan,
    :class_name => 'Kbase::OdtTimeSpan',
    :foreign_key => "odttimespanid"
  
  belongs_to :odttimespanpool,
    :class_name => 'Kbase::OdtTimeSpan',
    :foreign_key => "odttimespanpoolid"

end

