class Kbase::OdtTimeSpan < ApplicationRecord
  establish_connection :kbase42222
  self.table_name = 'odttimespan'
  self.primary_key = 'id'

  attribute :id, :integer
  
  belongs_to :opdaytmpl,
    :class_name => 'Kbase::OpDayTmpl',
    :foreign_key => "odtid"

  has_many :odtcalendars,
    :through => :opdaytmpl
  
end

